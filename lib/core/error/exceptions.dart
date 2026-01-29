class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (statusCode: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class UnauthorizedException extends ServerException {
  UnauthorizedException({super.message = 'غير مصرح لك بالدخول'})
      : super(statusCode: 401);
}

class NotFoundException extends ServerException {
  NotFoundException({super.message = 'العنصر غير موجود'})
      : super(statusCode: 404);
}

class NetworkException extends ServerException {
  NetworkException({super.message = 'مشكلة في الاتصال بالإنترنت'});
}
