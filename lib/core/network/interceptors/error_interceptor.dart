import 'package:dio/dio.dart';
import 'package:mint_talk/core/errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Map DioExceptions to our domain exceptions
    final response = err.response;
    final statusCode = response?.statusCode;

    // 1. Check for connection / network timeouts
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      throw const NetworkException(message: 'Network connection timeout. Please check your internet.');
    }

    if (err.type == DioExceptionType.cancel) {
      throw const NetworkException(message: 'Request cancelled.');
    }

    // 2. Map response status codes
    if (response != null) {
      final responseData = response.data;
      String message = 'Something went wrong';
      
      if (responseData is Map<String, dynamic>) {
        message = responseData['message'] ?? responseData['error'] ?? message;
      }

      if (statusCode == 401 || statusCode == 403) {
        throw UnauthorizedException(message: message);
      }

      if (statusCode == 429) {
        throw RateLimitException(message: message);
      }

      throw ServerException(message: message, statusCode: statusCode);
    }

    // 3. Fallback network exception
    throw const NetworkException();
  }
}
