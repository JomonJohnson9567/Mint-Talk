import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    // See post() below for why these are left null (inherit the 60s
    // BaseOptions default) for every existing caller.
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) async {
    final response = await _dio.get(
      endpoint,
      queryParameters: queryParams,
      options: Options(
        extra: {'requiresAuth': requiresAuth},
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
      ),
      cancelToken: cancelToken,
    );
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, dynamic>? body,
    CancelToken? cancelToken,
    // Left null for every existing caller, which keeps inheriting the
    // BaseOptions default (60s) unchanged. Only a latency-sensitive request
    // that the caller intends to retry (e.g. ending a call) should pass a
    // shorter value here so a stalled attempt fails fast enough to matter.
    // connectTimeout matters just as much as sendTimeout/receiveTimeout: a
    // request that never even establishes a connection (as opposed to one
    // that connects but responds slowly) is governed by connectTimeout, not
    // the other two — leaving it at the 60s default would silently defeat
    // the point of shortening the others.
    Duration? connectTimeout,
    Duration? sendTimeout,
    Duration? receiveTimeout,
  }) async {
    final response = await _dio.post(
      endpoint,
      data: body,
      options: Options(
        extra: {'requiresAuth': requiresAuth},
        connectTimeout: connectTimeout,
        sendTimeout: sendTimeout,
        receiveTimeout: receiveTimeout,
      ),
      cancelToken: cancelToken,
    );
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return <String, dynamic>{};
  }

  /// Send a POST request with multipart form data (for file uploads).
  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    bool requiresAuth = false,
    required Map<String, dynamic> body,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap(body);
    final response = await _dio.post(
      endpoint,
      data: formData,
      options: Options(extra: {'requiresAuth': requiresAuth}),
      cancelToken: cancelToken,
    );
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return <String, dynamic>{};
  }

  /// Send a PATCH request with a JSON [body].
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, dynamic>? body,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.patch(
      endpoint,
      data: body,
      options: Options(extra: {'requiresAuth': requiresAuth}),
      cancelToken: cancelToken,
    );
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return <String, dynamic>{};
  }

  /// Send a DELETE request.
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = false,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.delete(
      endpoint,
      options: Options(extra: {'requiresAuth': requiresAuth}),
      cancelToken: cancelToken,
    );
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return <String, dynamic>{};
  }

  /// Access the raw Dio Response (needed for extracting headers, e.g. cookies).
  Future<Response> postRaw(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, dynamic>? body,
    CancelToken? cancelToken,
  }) async {
    return _dio.post(
      endpoint,
      data: body,
      options: Options(extra: {'requiresAuth': requiresAuth}),
      cancelToken: cancelToken,
    );
  }
}
