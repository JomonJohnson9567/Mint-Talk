import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/network/interceptors/server_time_interceptor.dart';
import 'package:mint_talk/core/utils/server_clock.dart';

/// Answers every request with [statusCode] and an optional Date header.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({this.date, this.statusCode = 200});

  final String? date;
  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString('{}', statusCode, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      if (date != null) HttpHeaders.dateHeader: [date!],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const baseUrl = 'https://api.example.test/api/v1';
  // A device clock 90 s fast relative to the server.
  final serverNow = DateTime.now().toUtc().subtract(const Duration(seconds: 90));

  late ServerClock clock;

  Dio dioWith(_StubAdapter adapter) {
    return Dio(BaseOptions(baseUrl: baseUrl))
      ..httpClientAdapter = adapter
      ..interceptors.add(ServerTimeInterceptor(clock));
  }

  setUp(() => clock = ServerClock());

  void expectSyncedToServer() {
    expect(clock.isSynced, isTrue);
    // Within the header's 1 s resolution plus test overhead.
    expect(
      clock.now().difference(serverNow).inMilliseconds.abs(),
      lessThan(2000),
    );
  }

  test('a backend response with a Date header syncs the clock', () async {
    await dioWith(_StubAdapter(date: HttpDate.format(serverNow))).get('/hosts');
    expectSyncedToServer();
  });

  test('an error response still syncs the clock', () async {
    final dio = dioWith(_StubAdapter(date: HttpDate.format(serverNow), statusCode: 500));
    await expectLater(dio.get('/hosts'), throwsA(isA<DioException>()));
    expectSyncedToServer();
  });

  test('a missing or malformed Date header is ignored', () async {
    await dioWith(_StubAdapter()).get('/hosts');
    await dioWith(_StubAdapter(date: 'not a date')).get('/hosts');
    expect(clock.isSynced, isFalse);
  });

  test('responses from another host are ignored', () async {
    await dioWith(_StubAdapter(date: HttpDate.format(serverNow)))
        .get('https://cdn.example.test/image.jpg');
    expect(clock.isSynced, isFalse);
  });
}
