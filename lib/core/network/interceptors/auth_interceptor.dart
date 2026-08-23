import 'package:dio/dio.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';

class AuthInterceptor extends Interceptor {
  /// The shared, fully-configured Dio instance this interceptor is attached
  /// to. Used to retry a request after a successful token refresh so the
  /// retried request still goes through logging/error-mapping/cert-pinning,
  /// instead of a bare throwaway Dio() that bypasses all of it. Passed in
  /// (rather than resolved via [getIt]) because [DioModule.dio] constructs
  /// this interceptor before the instance it attaches to is fully built.
  final Dio _dio;

  AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Attach Access Token as Bearer Header — only for requests that opted
    // in via `ApiClient(requiresAuth: true)`. Public/pre-auth endpoints
    // (send-otp, verify-otp) pass `requiresAuth: false` and never get a
    // token attached, so a stale/expired session can't leak into a call
    // that doesn't need one.
    if (options.extra['requiresAuth'] == true) {
      final tokenManager = getIt<TokenManager>();

      var accessToken = tokenManager.getAccessToken();
      if ((accessToken == null || accessToken.isEmpty) &&
          await tokenManager.hasRefreshToken()) {
        await tokenManager.refreshAccessToken();
        accessToken = tokenManager.getAccessToken();
      }

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    // 2. Remove Content-Type header for multipart/form-data to let Dio generate boundaries
    if (options.data is FormData) {
      options.headers.remove('Content-Type');
      options.headers.remove('content-type');
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final statusCode = response?.statusCode;

    // Only treat a 401 as a session expiry when it came from a request that
    // actually required auth. Pre-auth endpoints (send-otp, verify-otp) pass
    // `requiresAuth: false` and can legitimately return 401 for things like
    // a wrong OTP — that must surface as a normal failure to the caller
    // (e.g. so the OTP screen can show an inline error and let the user
    // retry) instead of clearing tokens and redirecting to the phone number
    // screen.
    final requiredAuth = err.requestOptions.extra['requiresAuth'] == true;
    if (statusCode == 401 && requiredAuth) {
      final tokenManager = getIt<TokenManager>();

      // Avoid infinite loop if the refresh attempt itself or the retried request fails again
      if (err.requestOptions.extra['isRetry'] == true) {
        await tokenManager.clearAll();
        return handler.next(err);
      }

      final refreshed = await tokenManager.refreshAccessToken();

      if (refreshed) {
        final options = err.requestOptions;
        options.extra['isRetry'] = true;

        // Apply new credentials
        final newAccessToken = tokenManager.getAccessToken();
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $newAccessToken';
        }

        try {
          // Retry on the shared, intercepted Dio instance (not a throwaway
          // one) so the retried request still gets logging/error-mapping/
          // cert-pinning. Safe from infinite recursion because `options`
          // already carries `extra['isRetry'] = true`, which the guard at
          // the top of this method checks on the next pass.
          final retryResponse = await _dio.fetch(options);
          return handler.resolve(retryResponse);
        } on DioException catch (retryErr) {
          return handler.next(retryErr);
        }
      } else {
        await tokenManager.clearAll();
        // Redirect to login screen on session expiry
        getIt<NavigationService>().navigateAndRemoveUntil(
          AppRoutes.phoneNumber,
        );
      }
    }

    return handler.next(err);
  }
}
