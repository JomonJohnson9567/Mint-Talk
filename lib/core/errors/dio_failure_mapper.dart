import 'package:dio/dio.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/errors/failures.dart';

/// Single source of truth for turning a [DioException] into a typed [Failure].
///
/// [ErrorInterceptor] maps every network error into one of our domain
/// exceptions (`ServerException`/`NetworkException`/`UnauthorizedException`/
/// `RateLimitException`) and carries it in [DioException.error] via
/// `handler.reject(...)`. Dio's own contract always throws a [DioException]
/// from request methods (never the raw mapped exception directly), so every
/// repository/data source must catch `DioException` and read `.error` to
/// recover the specific failure type — this helper does that consistently
/// instead of every call site re-implementing its own subset of the mapping.
Failure mapDioExceptionToFailure(DioException e, {String? fallbackMessage}) {
  final mapped = e.error;

  if (mapped is UnauthorizedException) {
    return UnauthorizedFailure(message: mapped.message);
  }
  if (mapped is RateLimitException) {
    return RateLimitFailure(message: mapped.message);
  }
  if (mapped is NetworkException) {
    return NetworkFailure(message: mapped.message);
  }
  if (mapped is ServerException) {
    return ServerFailure(message: mapped.message, statusCode: mapped.statusCode);
  }

  // Defensive fallback for the (normal) case where a request never reached
  // ErrorInterceptor's mapping — e.g. it was cancelled before dispatch, or
  // this call site talks to Dio outside the shared, intercepted instance.
  final responseData = e.response?.data;
  final statusCode = e.response?.statusCode;
  String? message;
  if (responseData is Map<String, dynamic>) {
    message = responseData['message'] ?? responseData['error'];
  }
  message ??= fallbackMessage ?? 'Something went wrong';

  if (statusCode == 401 || statusCode == 403) {
    return UnauthorizedFailure(message: message);
  }
  if (statusCode == 429) {
    return RateLimitFailure(message: message);
  }
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError) {
    return NetworkFailure(message: message);
  }
  return ServerFailure(message: message, statusCode: statusCode);
}
