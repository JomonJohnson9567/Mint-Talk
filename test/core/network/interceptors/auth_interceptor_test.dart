import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/interceptors/auth_interceptor.dart';
import 'package:mint_talk/core/services/session/session_manager.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mocktail/mocktail.dart';

class _MockTokenManager extends Mock implements TokenManager {}

class _MockSessionManager extends Mock implements SessionManager {}

/// Answers every retried request with a 200 and records the Authorization
/// header it was sent with.
class _StubAdapter implements HttpClientAdapter {
  final List<Object?> authHeaders = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    authHeaders.add(options.headers['Authorization']);
    return ResponseBody.fromString('{}', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

/// [ErrorInterceptorHandler.next]/[.reject] complete an internal completer
/// that isn't exposed to callers outside the dio package — if nothing ever
/// listens to it, Dart's zone reports the error as "unhandled" once the test
/// finishes, failing the test even though the interceptor itself behaved
/// correctly. Overriding the public entry points instead of calling through
/// to the real completer sidesteps that entirely and gives tests a simple
/// way to assert what the interceptor decided to do.
class _RecordingErrorHandler extends ErrorInterceptorHandler {
  DioException? passedThrough;
  Response? resolvedWith;

  @override
  void next(DioException err) {
    passedThrough = err;
  }

  @override
  void reject(DioException err) {
    passedThrough = err;
  }

  @override
  void resolve(Response response) {
    resolvedWith = response;
  }
}

/// Same reasoning as [_RecordingErrorHandler], for the request side.
class _RecordingRequestHandler extends RequestInterceptorHandler {
  RequestOptions? forwarded;
  DioException? rejectedWith;

  @override
  void next(RequestOptions requestOptions) {
    forwarded = requestOptions;
  }

  @override
  void reject(
    DioException error, [
    bool callFollowingErrorInterceptor = false,
  ]) {
    rejectedWith = error;
  }
}

void main() {
  late _MockTokenManager tokenManager;
  late _MockSessionManager sessionManager;
  late AuthInterceptor interceptor;
  late Dio dio;
  late _StubAdapter adapter;

  setUp(() {
    tokenManager = _MockTokenManager();
    sessionManager = _MockSessionManager();

    // AuthInterceptor resolves these via getIt internally rather than
    // constructor injection (a known service-locator leak — out of scope to
    // fix here), so tests register mocks into the same container.
    getIt.registerSingleton<TokenManager>(tokenManager);
    getIt.registerSingleton<SessionManager>(sessionManager);

    when(() => sessionManager.forceLogout(
          message: any(named: 'message'),
          silent: any(named: 'silent'),
        )).thenAnswer((_) async {});

    adapter = _StubAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    interceptor = AuthInterceptor(dio);
  });

  tearDown(() async {
    await getIt.reset();
  });

  // Defaults to `requiresAuth: true` since that's what every pre-existing
  // test here exercises; the `onRequest` group below overrides it to `false`
  // for the opt-out case.
  RequestOptions requestOptions({
    Map<String, dynamic>? extra,
    bool requiresAuth = true,
  }) => RequestOptions(
        path: '/some/endpoint',
        baseUrl: 'https://example.test',
        extra: {'requiresAuth': requiresAuth, ...?extra},
      );

  DioException unauthorized({
    Map<String, dynamic>? extra,
    String? sentWith,
  }) {
    final options = requestOptions(extra: extra);
    if (sentWith != null) options.headers['Authorization'] = 'Bearer $sentWith';
    return DioException(
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: 401),
    );
  }

  void verifyNoLogout() => verifyNever(() => sessionManager.forceLogout(
        message: any(named: 'message'),
        silent: any(named: 'silent'),
      ));

  group('onRequest', () {
    test('attaches Bearer header when an access token is already available', () async {
      when(() => tokenManager.getAccessToken()).thenReturn('access-123');

      final options = requestOptions();
      final handler = _RecordingRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer access-123');
      verifyNever(() => tokenManager.hasRefreshToken());
    });

    test('does not attach a header when there is no access token and no refresh token', () async {
      when(() => tokenManager.getAccessToken()).thenReturn(null);
      when(() => tokenManager.hasRefreshToken()).thenAnswer((_) async => false);

      final options = requestOptions();
      final handler = _RecordingRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      expect(handler.forwarded, same(options));
    });

    test('does not attach a header (or touch TokenManager) when requiresAuth is false, even with a valid token available', () async {
      final options = requestOptions(requiresAuth: false);
      final handler = _RecordingRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verifyZeroInteractions(tokenManager);
    });

    test('a rejected pre-flight refresh (cold start, stale token) logs out silently and never sends the request', () async {
      when(() => tokenManager.getAccessToken()).thenReturn(null);
      when(() => tokenManager.hasRefreshToken()).thenAnswer((_) async => true);
      when(() => tokenManager.refreshAccessToken())
          .thenAnswer((_) async => RefreshResult.rejected);

      final handler = _RecordingRequestHandler();
      await interceptor.onRequest(requestOptions(), handler);

      expect(handler.forwarded, isNull);
      expect(handler.rejectedWith?.error, isA<UnauthorizedException>());
      verify(() => sessionManager.forceLogout(
            message: any(named: 'message'),
            silent: true,
          )).called(1);
    });

    test('a transient pre-flight refresh failure still sends the request and keeps the session', () async {
      when(() => tokenManager.getAccessToken()).thenReturn(null);
      when(() => tokenManager.hasRefreshToken()).thenAnswer((_) async => true);
      when(() => tokenManager.refreshAccessToken())
          .thenAnswer((_) async => RefreshResult.transientFailure);

      final options = requestOptions();
      final handler = _RecordingRequestHandler();
      await interceptor.onRequest(options, handler);

      expect(handler.forwarded, same(options));
      verifyNoLogout();
    });
  });

  group('onError', () {
    test('a non-401 error is passed through untouched', () async {
      final err = DioException(
        requestOptions: requestOptions(),
        response: Response(requestOptions: requestOptions(), statusCode: 500),
      );
      final handler = _RecordingErrorHandler();

      await interceptor.onError(err, handler);

      expect(handler.passedThrough, same(err));
      verifyZeroInteractions(tokenManager);
      verifyZeroInteractions(sessionManager);
    });

    test('a 401 with isRetry already set is surfaced without another refresh or a logout', () async {
      final err = unauthorized(extra: {'isRetry': true});
      final handler = _RecordingErrorHandler();

      await interceptor.onError(err, handler);

      expect(handler.passedThrough, same(err));
      verifyNoLogout();
      verifyNever(() => tokenManager.refreshAccessToken());
    });

    test('a 401 on a token another request already refreshed is retried with the current token, without refreshing', () async {
      when(() => tokenManager.getAccessToken()).thenReturn('new-token');

      final handler = _RecordingErrorHandler();
      await interceptor.onError(unauthorized(sentWith: 'old-token'), handler);

      expect(handler.resolvedWith?.statusCode, 200);
      expect(adapter.authHeaders, ['Bearer new-token']);
      verifyNever(() => tokenManager.refreshAccessToken());
      verifyNoLogout();
    });

    test('a 401 on the current token refreshes and retries with the new one', () async {
      var token = 'old-token';
      when(() => tokenManager.getAccessToken()).thenAnswer((_) => token);
      when(() => tokenManager.refreshAccessToken()).thenAnswer((_) async {
        token = 'new-token';
        return RefreshResult.success;
      });

      final handler = _RecordingErrorHandler();
      await interceptor.onError(unauthorized(sentWith: 'old-token'), handler);

      expect(handler.resolvedWith?.statusCode, 200);
      expect(adapter.authHeaders, ['Bearer new-token']);
      verify(() => tokenManager.refreshAccessToken()).called(1);
      verifyNoLogout();
    });

    test('a 401 whose refresh is rejected (revoked session) forces logout', () async {
      when(() => tokenManager.refreshAccessToken())
          .thenAnswer((_) async => RefreshResult.rejected);

      final err = unauthorized();
      final handler = _RecordingErrorHandler();

      await interceptor.onError(err, handler);

      expect(handler.passedThrough, same(err));
      verify(() => sessionManager.forceLogout(message: any(named: 'message'))).called(1);
    });

    test('a 401 whose refresh fails on the network keeps the session', () async {
      when(() => tokenManager.refreshAccessToken())
          .thenAnswer((_) async => RefreshResult.transientFailure);

      final err = unauthorized();
      final handler = _RecordingErrorHandler();

      await interceptor.onError(err, handler);

      expect(handler.passedThrough, same(err));
      verifyNoLogout();
      verifyNever(() => tokenManager.clearAll());
    });

    test('a 401 on a request that opted out of session handling is passed through', () async {
      final err = unauthorized(extra: {'skipSessionHandling': true});
      final handler = _RecordingErrorHandler();

      await interceptor.onError(err, handler);

      expect(handler.passedThrough, same(err));
      verifyZeroInteractions(tokenManager);
      verifyZeroInteractions(sessionManager);
    });
  });
}
