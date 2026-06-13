import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// Send a GET request to the given [endpoint].
  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await _dio.get(
      endpoint,
      queryParameters: queryParams,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Send a POST request with a JSON [body].
  Future<Map<String, dynamic>> post(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.post(
      endpoint,
      data: body,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Send a PATCH request with a JSON [body].
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.patch(
      endpoint,
      data: body,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Send a DELETE request.
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    final response = await _dio.delete(
      endpoint,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Access the raw Dio Response (needed for extracting headers, e.g. cookies).
  Future<Response> postRaw(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, dynamic>? body,
  }) async {
    return _dio.post(
      endpoint,
      data: body,
    );
  }
}
