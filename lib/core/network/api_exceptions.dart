import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = 'Unauthorized'})
      : super(message: message, statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException({String message = 'Forbidden'})
      : super(message: message, statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException({String message = 'Not found'})
      : super(message: message, statusCode: 404);
}

class BadRequestException extends ApiException {
  BadRequestException({String message = 'Bad request'})
      : super(message: message, statusCode: 400);
}

class ServerException extends ApiException {
  ServerException({String message = 'Internal server error'})
      : super(message: message, statusCode: 500);
}

class NetworkException extends ApiException {
  NetworkException({String message = 'No internet connection'})
      : super(message: message, statusCode: null);
}

/// Message cố định cho lỗi mất mạng/timeout/server không phản hồi — dùng
/// làm hằng số (thay vì string literal rải rác) để UI so sánh
/// `provider.error == kNetworkErrorMessage` và quyết định hiện popup
/// [showConnectionErrorDialog] thay vì toast thường.
const String kNetworkErrorMessage = 'Không có kết nối mạng hoặc máy chủ không phản hồi.';

/// Rút ra message tiếng Việt, dễ hiểu cho người dùng từ lỗi bắt được trong
/// try/catch của provider — dùng thay cho `e.toString()` (in ra kiểu
/// "DioException [unknown]: null", vô nghĩa với người dùng cuối).
///
/// DioClient._mapError luôn bọc lỗi thật vào field `error` của DioException
/// nên phải bóc `.error` ra trước khi đọc message.
String apiErrorMessage(
  dynamic e, {
  String fallback = 'Không thể kết nối máy chủ, vui lòng thử lại.',
}) {
  final error = e is DioException ? e.error : e;
  if (error is NetworkException) {
    return kNetworkErrorMessage;
  }
  if (error is ApiException) {
    return error.message;
  }
  return fallback;
}

/// true nếu message lỗi (String? lấy từ provider.error) là lỗi mất
/// mạng/timeout — dùng ở UI để quyết định hiện popup thay vì toast.
bool isNetworkErrorMessage(String? message) => message == kNetworkErrorMessage;
