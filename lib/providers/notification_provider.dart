import 'package:flutter/material.dart';
import 'package:event_app/services/notification_service.dart';
import 'package:event_app/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;

  NotificationProvider(this._notificationService);

  bool _isLoading = false;
  String? _error;
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  int _currentPage = 0;
  int _totalPages = 1;
  bool _hasMore = true;
  int _newNotificationTick = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _hasMore;

  /// Tăng mỗi khi có 1 push FCM đến lúc app đang mở (foreground) — UI (biểu
  /// tượng chuông) theo dõi giá trị này để kích hoạt hiệu ứng rung, kể cả
  /// khi unreadCount không đổi giữa 2 lần tick (VD: người dùng đang mở màn
  /// Thông báo, chưa kịp reload count, nhưng vẫn nên thấy chuông rung).
  int get newNotificationTick => _newNotificationTick;

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _notifications.clear();
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _setLoading(true);
    try {
      final result = await _notificationService.getNotifications(
        page: _currentPage,
        size: 20,
      );

      final items = result['content'] as List<NotificationModel>;
      _notifications.addAll(items);
      _totalPages = result['totalPages'] as int;
      _currentPage++;
      _hasMore = _currentPage < _totalPages;

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadMore() async {
    await loadNotifications(refresh: false);
  }

  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load unread count: $e');
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _notificationService.markAsRead(id);

      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].markRead();
        if (_unreadCount > 0) _unreadCount--;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    _setLoading(true);
    try {
      await _notificationService.markAllAsRead();

      _notifications = _notifications.map((n) => n.markRead()).toList();
      _unreadCount = 0;

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Gọi từ FcmService khi nhận được push lúc app đang foreground — không
  /// tự cộng unreadCount ở đây (số chính xác luôn đến từ loadUnreadCount()
  /// gọi backend), chỉ dùng để báo UI "vừa có thông báo mới, hãy rung
  /// chuông".
  void notifyNewNotification() {
    _newNotificationTick++;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}
