import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mint_talk/core/utils/server_clock.dart';

/// Feeds [ServerClock] from the `Date` header of every backend response, so
/// server timestamps (call `activeAt`, …) can be compared against server
/// time rather than the device clock.
///
/// Registered last in the interceptor chain so the send timestamp is taken
/// right before the request leaves (after any token lookup/refresh in
/// `AuthInterceptor`), keeping the round-trip estimate tight.
class ServerTimeInterceptor extends Interceptor {
  ServerTimeInterceptor(this._clock);

  final ServerClock _clock;

  static const String _sentAtKey = '_serverTimeSentAt';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_sentAtKey] = _clock.monotonicNow;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _sample(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // A 4xx/5xx still carries the server's Date header.
    final response = err.response;
    if (response != null) _sample(response);
    handler.next(err);
  }

  void _sample(Response response) {
    final receivedAt = _clock.monotonicNow;
    final options = response.requestOptions;

    final sentAt = options.extra[_sentAtKey];
    if (sentAt is! Duration) return;
    if (!_isBackendRequest(options)) return;

    final header = response.headers.value(HttpHeaders.dateHeader);
    if (header == null) return;

    final DateTime serverDate;
    try {
      serverDate = HttpDate.parse(header);
    } on HttpException {
      return;
    } on FormatException {
      return;
    }

    _clock.observe(
      serverDate: serverDate,
      sentAt: sentAt,
      receivedAt: receivedAt,
    );
  }

  /// Only our own API's clock matters; an absolute URL to another host (a
  /// CDN, S3) is ignored.
  bool _isBackendRequest(RequestOptions options) {
    final base = Uri.tryParse(options.baseUrl);
    if (base == null || base.host.isEmpty) return false;
    return options.uri.host == base.host;
  }
}
