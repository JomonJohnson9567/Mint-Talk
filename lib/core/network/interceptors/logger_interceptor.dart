import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Payout fields never written to the debug log, wherever they appear in a
/// request/response body (withdrawal history, payout accounts, …).
const _sensitiveKeys = {
  'accountnumber',
  'ifsc',
  'upiid',
  'vpa',
  'holdername',
  'accountholdername',
  'payoutdetails',
};

/// Returns a copy of [data] with every [_sensitiveKeys] value replaced, so
/// bank/UPI details can't leak through the API log.
@visibleForTesting
Object? redactSensitive(Object? data) {
  if (data is Map) {
    return {
      for (final entry in data.entries)
        entry.key: _sensitiveKeys.contains(entry.key.toString().toLowerCase())
            ? '<redacted>'
            : redactSensitive(entry.value),
    };
  }
  if (data is List) return data.map(redactSensitive).toList();
  return data;
}

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
          'Data: ${redactSensitive(options.data)}');
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.i('⬅️ API RESPONSE: [${response.statusCode}] ${response.requestOptions.uri}\n'
          'Data: ${redactSensitive(response.data)}');
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final responseData = err.response?.data;
      final message = responseData is Map ? responseData['message'] : null;
      final isVersionConflict = err.response?.statusCode == 400 &&
          message is String &&
          message.contains('No matching document found');

      if (isVersionConflict) {
        _logger.w('⚠️ VERSION CONFLICT (expected race, ignored): '
            '${err.requestOptions.uri}\n$message');
      } else {
        _logger.e('❌ API ERROR: [${err.response?.statusCode}] ${err.requestOptions.uri}\n'
            'Message: ${err.message}\n'
            'Error: ${err.error}\n'
            'Response: ${redactSensitive(err.response?.data)}');
      }
    }
    return handler.next(err);
  }
}
