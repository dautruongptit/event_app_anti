import 'package:event_app/core/constants/api_constants.dart';
import 'package:event_app/core/network/dio_client.dart';
import 'package:event_app/models/notification_model.dart';

class NotificationService {
  final DioClient _dio;
  NotificationService(this._dio);

  Future<Map<String, dynamic>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.notifications,
      queryParameters: {'page': page, 'size': size},
    );
    final data = response.data['data'];
    // Handle both paginated and list responses
    if (data is Map) {
      return {
        'content': (data['content'] as List)
            .map((e) => NotificationModel.fromJson(e))
            .toList(),
        'totalPages': data['totalPages'] as int? ?? 1,
        'totalElements': data['totalElements'] as int? ?? 0,
      };
    }
    // If backend returns a direct list
    final list = (data as List)
        .map((e) => NotificationModel.fromJson(e))
        .toList();
    return {
      'content': list,
      'totalPages': 1,
      'totalElements': list.length,
    };
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiConstants.unreadCount);
    return response.data['data'] as int;
  }

  Future<NotificationModel> markAsRead(int id) async {
    final response = await _dio.put(ApiConstants.markAsRead(id));
    return NotificationModel.fromJson(response.data['data']);
  }

  Future<void> markAllAsRead() async {
    await _dio.put(ApiConstants.markAllAsRead);
  }
}
