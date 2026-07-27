import 'dart:io';
import 'package:dio/dio.dart';
import 'package:event_app/core/constants/api_constants.dart';
import 'package:event_app/core/network/dio_client.dart';
import 'package:event_app/models/auth_response.dart';
import 'package:event_app/models/user.dart';

class AuthService {
  final DioClient _dio;
  AuthService(this._dio);

  Future<AuthResponse> register(String fullName, String email, String password) async {
    final response = await _dio.post(ApiConstants.register, data: {
      'fullName': fullName,
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(response.data['data']);
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(response.data['data']);
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await _dio.post(ApiConstants.refresh, data: {
      'refreshToken': refreshToken,
    });
    return AuthResponse.fromJson(response.data['data']);
  }

  Future<void> logout() async {
    await _dio.post(ApiConstants.logout);
  }

  Future<UserProfile> updateProfile(String fullName) async {
    final response = await _dio.put(ApiConstants.updateProfile, data: {
      'fullName': fullName,
    });
    return UserProfile.fromJson(response.data['data']);
  }

  Future<UserProfile> updateSettings({String? language, bool? darkMode}) async {
    final data = <String, dynamic>{};
    if (language != null) data['language'] = language;
    if (darkMode != null) data['darkMode'] = darkMode;
    final response = await _dio.put(ApiConstants.updateSettings, data: data);
    return UserProfile.fromJson(response.data['data']);
  }

  Future<UserProfile> uploadAvatar(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    final response = await _dio.post(ApiConstants.uploadAvatar, data: formData);
    return UserProfile.fromJson(response.data['data']);
  }

  Future<void> connectGoogleCalendar(String code) async {
    await _dio.post(ApiConstants.connectGoogleCalendar, data: {
      'code': code,
    });
  }
}
