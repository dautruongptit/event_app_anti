import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'api_exceptions.dart';

class DioClient {
  late final Dio _dio;
  final SharedPreferences _prefs;
  Function()? tokenExpiredCallback;

  DioClient(this._prefs) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final skipAuthRoutes = [
          ApiConstants.login,
          ApiConstants.register,
          ApiConstants.refresh,
          ApiConstants.googleLogin,
        ];

        if (!skipAuthRoutes.contains(options.path)) {
          final token = _prefs.getString('accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 && e.requestOptions.path != ApiConstants.refresh) {
          final refreshToken = _prefs.getString('refreshToken');
          if (refreshToken != null) {
            try {
              final dioRefresh = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
              final response = await dioRefresh.post(
                ApiConstants.refresh,
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200) {
                final newAccessToken = response.data['accessToken'];
                final newRefreshToken = response.data['refreshToken'];
                
                await _prefs.setString('accessToken', newAccessToken);
                await _prefs.setString('refreshToken', newRefreshToken);

                e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                
                final retryResponse = await _dio.fetch(e.requestOptions);
                return handler.resolve(retryResponse);
              }
            } catch (refreshErr) {
              await _prefs.remove('accessToken');
              await _prefs.remove('refreshToken');
              tokenExpiredCallback?.call();
              return handler.reject(
                DioException(
                  requestOptions: e.requestOptions,
                  error: UnauthorizedException(message: 'Session expired'),
                )
              );
            }
          } else {
            tokenExpiredCallback?.call();
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: UnauthorizedException(message: 'Session expired'),
              )
            );
          }
        }

        return handler.reject(_mapError(e));
      },
    ));
  }

  DioException _mapError(DioException e) {
    ApiException exception;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        exception = NetworkException(message: 'Connection error');
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'An error occurred';
        if (statusCode == 400) {
          exception = BadRequestException(message: message);
        } else if (statusCode == 401) {
          exception = UnauthorizedException(message: message);
        } else if (statusCode == 403) {
          exception = ForbiddenException(message: message);
        } else if (statusCode == 404) {
          exception = NotFoundException(message: message);
        } else {
          exception = ServerException(message: message);
        }
        break;
      default:
        exception = ServerException(message: 'Unknown error occurred');
    }
    // Giữ lại type gốc + gán message từ exception vừa map — nếu không,
    // DioException mới sẽ có type mặc định "unknown" và message null,
    // khiến e.toString() vô nghĩa (VD: "DioException [unknown]: null").
    return DioException(
      requestOptions: e.requestOptions,
      error: exception,
      type: e.type,
      message: exception.message,
    );
  }

  Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(url, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(String url, {dynamic data}) async {
    try {
      return await _dio.post(url, data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(String url, {dynamic data}) async {
    try {
      return await _dio.put(url, data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String url, {dynamic data}) async {
    try {
      return await _dio.delete(url, data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> multipartUpload(String url, FormData formData) async {
    try {
      return await _dio.post(
        url,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } catch (e) {
      rethrow;
    }
  }
}
