import 'package:dio/dio.dart';
import 'package:mint_talk/core/errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Map DioExceptions to our domain exceptions.
    //
    // IMPORTANT: this must call handler.reject(...), never `throw`. Dio's
    // internals catch anything thrown out of onError and re-wrap it as a
    // brand-new DioException(type: unknown), discarding the mapped
    // exception's type — which silently defeated every `on ServerException`/
    // `on NetworkException`/etc. catch clause elsewhere in the app. Passing
    // the mapped exception through DioException.error via reject() is what
    // actually lets it reach call sites as the intended type.
    final response = err.response;
    final statusCode = response?.statusCode;

    final Exception mapped = _mapException(err, response, statusCode);

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: mapped,
        stackTrace: err.stackTrace,
      ),
    );
  }

  Exception _mapException(DioException err, Response? response, int? statusCode) {
    // 1. Check for connection / network timeouts
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return const NetworkException(message: 'Network connection timeout. Please check your internet.');
    }

    if (err.type == DioExceptionType.cancel) {
      return const NetworkException(message: 'Request cancelled.');
    }

    // 2. Map response status codes
    if (response != null) {
      final responseData = response.data;
      String message = 'Something went wrong';

      if (responseData is Map<String, dynamic>) {
        message = responseData['message'] ?? responseData['error'] ?? message;
      }

      if (statusCode == 401 || statusCode == 403) {
        return UnauthorizedException(message: message);
      }

      if (statusCode == 429) {
        return RateLimitException(message: message);
      }

      return ServerException(message: message, statusCode: statusCode);
    }

    // 3. Fallback network exception
    return const NetworkException();
  }
}
