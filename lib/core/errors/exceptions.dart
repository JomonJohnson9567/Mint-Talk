// Raw exceptions thrown from the data layer (remote data sources).
// Caught in repository implementations and converted to [Failure] types.

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException(message: $message, statusCode: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No internet connection'});

  @override
  String toString() => 'NetworkException(message: $message)';
}

class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException({this.message = 'Unauthorized'});

  @override
  String toString() => 'UnauthorizedException(message: $message)';
}

class RateLimitException implements Exception {
  final String message;

  const RateLimitException({this.message = 'Rate limit exceeded'});

  @override
  String toString() => 'RateLimitException(message: $message)';
}

class ValidationException implements Exception {
  final Map<String, String> errors;

  const ValidationException(this.errors);

  @override
  String toString() => 'ValidationException(errors: $errors)';
}
