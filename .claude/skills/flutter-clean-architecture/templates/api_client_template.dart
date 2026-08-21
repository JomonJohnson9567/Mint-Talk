import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Single shared wrapper around Dio. Datasources depend on this,
/// never on Dio directly.
@lazySingleton
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // attach auth token here, e.g.:
          // options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (error, handler) {
          // central place to log / map Dio errors
          handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
