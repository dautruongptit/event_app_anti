import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:event_app/core/router/app_router.dart';
import 'package:event_app/services/device_service.dart';

/// Kênh notification khớp với backend (FcmService.java —
/// AndroidNotification.setChannelId("event_reminders")).
const String _reminderChannelId = 'event_reminders';
const String _reminderChannelName = 'Nhắc sự kiện';
const String _reminderChannelDesc = 'Thông báo nhắc nhở sự kiện sắp tới';

/// Handler xử lý push khi app đang ở background/terminated. Bắt buộc là
/// top-level function (không phải method trong class) theo yêu cầu của
/// firebase_messaging — chạy trên isolate riêng nên phải tự init Firebase.
/// Không cần tự hiển thị notification ở đây: Android/iOS tự hiện notification
/// hệ thống cho message có "notification" payload (backend luôn gửi kèm) khi
/// app không ở foreground.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background message: ${message.messageId}');
}

/// Bọc toàn bộ luồng push notification: khởi tạo Firebase + local
/// notifications, xin quyền, đăng ký/hủy FCM token với backend, hiển thị
/// notification khi app đang mở (foreground), và điều hướng tới sự kiện khi
/// người dùng bấm vào notification.
class FcmService {
  final DeviceService _deviceService;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  FcmService(this._deviceService);

  String? _currentToken;

  /// Gọi 1 lần khi app khởi động (main.dart), trước khi có user đăng nhập.
  /// Chỉ setup hạ tầng (channel, listener) — CHƯA xin quyền hay đăng ký token,
  /// việc đó chỉ nên làm sau khi user đã đăng nhập (registerForCurrentUser).
  Future<void> init() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      // Thiếu google-services.json (Android) hoặc GoogleService-Info.plist
      // (iOS) sẽ rơi vào đây — app vẫn chạy bình thường, chỉ mất tính năng push.
      debugPrint('[FCM] Firebase.initializeApp thất bại, bỏ qua push: $e');
      return;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _initLocalNotifications();

    // App đang mở (foreground): FCM không tự hiện notification hệ thống,
    // phải tự hiện bằng flutter_local_notifications.
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // User bấm vào notification lúc app đang chạy nền (background).
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // App bị tắt hẳn, user bấm vào notification để mở app.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _currentToken = newToken;
      _registerToken(newToken);
    });
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        final eventId = response.payload;
        if (eventId != null) _navigateToEvent(eventId);
      },
    );

    const channel = AndroidNotificationChannel(
      _reminderChannelId,
      _reminderChannelName,
      description: _reminderChannelDesc,
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannelId,
          _reminderChannelName,
          channelDescription: _reminderChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['eventId'],
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final eventId = message.data['eventId'];
    if (eventId != null) _navigateToEvent(eventId);
  }

  void _navigateToEvent(String eventId) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) return;
    context.push('/events/$eventId');
  }

  /// Gọi sau khi user đăng nhập thành công (Google/email) — xin quyền
  /// notification, lấy FCM token, đăng ký với backend. Lỗi bị nuốt có chủ
  /// đích: không được làm hỏng luồng login đã thành công.
  Future<void> registerForCurrentUser() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[FCM] User từ chối quyền notification');
        return;
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      _currentToken = token;
      await _registerToken(token);
    } catch (e) {
      debugPrint('[FCM] Đăng ký device thất bại: $e');
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      await _deviceService.registerDevice(
        fcmToken: token,
        platform: Platform.isIOS ? 'IOS' : 'ANDROID',
      );
    } catch (e) {
      debugPrint('[FCM] Gửi token lên backend thất bại: $e');
    }
  }

  /// Gọi lúc logout — tránh backend tiếp tục gửi push cho thiết bị đã đăng
  /// xuất. Lỗi bị nuốt có chủ đích, không chặn luồng logout.
  Future<void> unregisterCurrentDevice() async {
    final token = _currentToken;
    if (token == null) return;
    try {
      await _deviceService.unregisterDevice(token);
    } catch (e) {
      debugPrint('[FCM] Hủy đăng ký device thất bại: $e');
    }
  }
}
