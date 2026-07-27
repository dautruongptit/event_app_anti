import 'package:event_app/core/constants/api_constants.dart';
import 'package:event_app/core/network/dio_client.dart';
import 'package:event_app/models/user.dart';

class UserService {
  final DioClient _dio;
  UserService(this._dio);

  Future<UserProfile> getProfile() async {
    final response = await _dio.get(ApiConstants.userProfile);
    return UserProfile.fromJson(response.data['data']);
  }
}
