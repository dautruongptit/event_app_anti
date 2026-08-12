import 'package:event_app/core/constants/api_constants.dart';
import 'package:event_app/core/network/dio_client.dart';
import 'package:event_app/models/event.dart';

class EventService {
  final DioClient _dio;
  EventService(this._dio);

  Future<List<EventModel>> getEvents({
    int? categoryId,
    int? relativeId,
    int? month,
    int? year,
  }) async {
    final queryParams = <String, dynamic>{};
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (relativeId != null) queryParams['relativeId'] = relativeId;
    if (month != null) queryParams['month'] = month;
    if (year != null) queryParams['year'] = year;

    final response = await _dio.get(
      ApiConstants.events,
      queryParameters: queryParams,
    );
    return (response.data['data'] as List)
        .map((e) => EventModel.fromJson(e))
        .toList();
  }

  Future<List<EventModel>> getUpcoming({int limit = 5}) async {
    final response = await _dio.get(
      ApiConstants.upcomingEvents,
      queryParameters: {'limit': limit},
    );
    return (response.data['data'] as List)
        .map((e) => EventModel.fromJson(e))
        .toList();
  }

  Future<EventModel> getById(int id) async {
    final response = await _dio.get(ApiConstants.eventById(id));
    return EventModel.fromJson(response.data['data']);
  }

  Future<EventModel> create(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.events, data: data);
    return EventModel.fromJson(response.data['data']);
  }

  Future<EventModel> update(int id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConstants.eventById(id), data: data);
    return EventModel.fromJson(response.data['data']);
  }

  Future<void> delete(int id) async {
    await _dio.delete(ApiConstants.eventById(id));
  }
}
