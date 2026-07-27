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
