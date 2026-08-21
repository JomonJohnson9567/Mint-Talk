import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/network/interceptors/auth_interceptor.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mocktail/mocktail.dart';

class _MockTokenManager extends Mock implements TokenManager {}

class _MockNavigationService extends Mock implements NavigationService {}

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

void main() {
  late _MockTokenManager tokenManager;
  late _MockNavigationService navigationService;
  late AuthInterceptor interceptor;
  late Dio dio;

  setUp(() {
    tokenManager = _MockTokenManager();
    navigationService = _MockNavigationService();

    // AuthInterceptor resolves these via getIt internally rather than
    // constructor injection (a known service-locator leak — out of scope to
    // fix here), so tests register mocks into the same container.
    getIt.registerSingleton<TokenManager>(tokenManager);
    getIt.registerSingleton<NavigationService>(navigationService);

    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
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

  group('onRequest', () {
    test('attaches Bearer header when an access token is already available', () async {
      when(() => tokenManager.getAccessToken()).thenReturn('access-123');

      final options = requestOptions();
      final handler = RequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer access-123');
      verifyNever(() => tokenManager.hasRefreshToken());
    });

    test('does not attach a header when there is no access token and no refresh token', () async {
      when(() => tokenManager.getAccessToken()).thenReturn(null);
      when(() => tokenManager.hasRefreshToken()).thenAnswer((_) async => false);

      final options = requestOptions();
      final handler = RequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
    });

    test('does not attach a header (or touch TokenManager) when requiresAuth is false, even with a valid token available', () async {
      final options = requestOptions(requiresAuth: false);
      final handler = RequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verifyZeroInteractions(tokenManager);
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
      verifyZeroInteractions(navigationService);
    });

    test('a 401 with isRetry already set clears tokens without attempting another refresh', () async {
      when(() => tokenManager.clearAll()).thenAnswer((_) async {});

      final err = DioException(
        requestOptions: requestOptions(extra: {'isRetry': true}),
        response: Response(
          requestOptions: requestOptions(extra: {'isRetry': true}),
          statusCode: 401,
        ),
      );
      final handler = _RecordingErrorHandler();

      await interceptor.onError(err, handler);

      expect(handler.passedThrough, same(err));
      verify(() => tokenManager.clearAll()).called(1);
      verifyNever(() => tokenManager.getRefreshToken());
    });

    test('a 401 with no stored refresh token clears session and redirects to login', () async {
      when(() => tokenManager.getRefreshToken()).thenAnswer((_) async => null);
      when(() => tokenManager.clearAll()).thenAnswer((_) async {});
      when(() => navigationService.navigateAndRemoveUntil(any())).thenAnswer((_) async => null);

      final err = DioException(
        requestOptions: requestOptions(),
        response: Response(requestOptions: requestOptions(), statusCode: 401),
      );
      final handler = _RecordingErrorHandler();

      await interceptor.onError(err, handler);

      expect(handler.passedThrough, same(err));
      verify(() => tokenManager.clearAll()).called(1);
      verify(() => navigationService.navigateAndRemoveUntil(AppRoutes.phoneNumber)).called(1);
    });
  });
}
