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
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return <String, dynamic>{};
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
  }) async {
    final formData = FormData.fromMap(body);
    final response = await _dio.post(
      endpoint,
      data: formData,
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
  }) async {
    final response = await _dio.patch(
      endpoint,
      data: body,
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
  }) async {
    final response = await _dio.delete(
      endpoint,
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
  }) async {
    return _dio.post(
      endpoint,
      data: body,
    );
  }
}
