import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggerInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 85,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.d('➡️ API REQUEST: [${options.method}] ${options.uri}\n'
          'Headers: ${options.headers}\n'
          'Data: ${options.data}');
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.i('⬅️ API RESPONSE: [${response.statusCode}] ${response.requestOptions.uri}\n'
          'Data: ${response.data}');
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.e('❌ API ERROR: [${err.response?.statusCode}] ${err.requestOptions.uri}\n'
          'Message: ${err.message}\n'
          'Error: ${err.error}\n'
          'Response: ${err.response?.data}');
    }
    return handler.next(err);
  }
}
