import 'package:event_app/core/constants/api_constants.dart';
import 'package:event_app/core/network/dio_client.dart';
import 'package:event_app/models/home_response.dart';
import 'package:event_app/models/event.dart';

class HomeService {
  final DioClient _dio;
  HomeService(this._dio);

  Future<HomeResponse> getHomeData() async {
    final response = await _dio.get(ApiConstants.home);
    return HomeResponse.fromJson(response.data['data']);
  }

  Future<List<EventModel>> getMyEvents() async {
    final response = await _dio.get(ApiConstants.myEvents);
    return (response.data['data'] as List)
        .map((e) => EventModel.fromJson(e))
        .toList();
  }
}
