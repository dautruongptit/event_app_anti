import 'package:event_app/core/constants/api_constants.dart';
import 'package:event_app/core/network/dio_client.dart';

/// Đăng ký / hủy đăng ký FCM token của thiết bị hiện tại với backend
/// (POST/DELETE /users/me/devices — xem DeviceController.java).
class DeviceService {
  final DioClient _dio;
  DeviceService(this._dio);

  Future<void> registerDevice({
    required String fcmToken,
    required String platform, // ANDROID, IOS, WEB
    String? deviceName,
  }) async {
    await _dio.post(ApiConstants.devices, data: {
      'fcmToken': fcmToken,
      'platform': platform,
      if (deviceName != null) 'deviceName': deviceName,
    });
  }

  Future<void> unregisterDevice(String fcmToken) async {
    await _dio.delete(ApiConstants.devices, data: {'fcmToken': fcmToken});
  }
}
