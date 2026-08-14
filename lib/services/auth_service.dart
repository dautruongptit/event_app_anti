import 'dart:io';
import 'package:dio/dio.dart';
import 'package:event_app/core/constants/api_constants.dart';
import 'package:event_app/core/network/dio_client.dart';
import 'package:event_app/models/auth_response.dart';
import 'package:event_app/models/login_history.dart';
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

  Future<AuthResponse> loginWithGoogle(String idToken) async {
    final response = await _dio.post(ApiConstants.googleLogin, data: {
      'idToken': idToken,
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
    // Backend map @PutMapping("/me/avatar") — phải dùng PUT, không phải POST
    final response = await _dio.put(ApiConstants.uploadAvatar, data: formData);
    return UserProfile.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> getLoginHistory({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.loginHistory,
      queryParameters: {'page': page, 'size': size},
    );
    final data = response.data['data'];
    // Backend trả Page<LoginHistoryResponse> -> có field 'content'
    if (data is Map) {
      return {
        'content': (data['content'] as List)
            .map((e) => LoginHistoryModel.fromJson(e))
            .toList(),
        'totalPages': data['totalPages'] as int? ?? 1,
        'totalElements': data['totalElements'] as int? ?? 0,
      };
    }
    final list = (data as List)
        .map((e) => LoginHistoryModel.fromJson(e))
        .toList();
    return {
      'content': list,
      'totalPages': 1,
      'totalElements': list.length,
    };
  }

  Future<void> connectGoogleCalendar(String code) async {
    await _dio.post(ApiConstants.connectGoogleCalendar, data: {
      'code': code,
    });
  }
}
