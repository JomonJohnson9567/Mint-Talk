import 'package:dio/dio.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/services/session/session_manager.dart';
import 'package:mint_talk/core/utils/token_manager.dart';

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
        final result = await tokenManager.refreshAccessToken();
        if (result == RefreshResult.rejected &&
            !_skipsSessionHandling(options)) {
          // The session is already dead — sending the request would only
          // come back 401 and land in onError for the same outcome. No access
          // token has been issued in this process yet, so this is a cold
          // start with a stale stored token (expired, or left in the iOS
          // Keychain across a reinstall): go to login without the dialog.
          await getIt<SessionManager>().forceLogout(silent: true);
          return handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              error: const UnauthorizedException(
                message: SessionManager.sessionExpiredMessage,
              ),
            ),
          );
        }
        // On a transient failure, send without a token: offline requests
        // fail as network errors, anything else comes back 401 and gets one
        // more refresh attempt in onError.
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
    if (statusCode == 401 &&
        requiredAuth &&
        !_skipsSessionHandling(err.requestOptions)) {
      final tokenManager = getIt<TokenManager>();

      // A freshly refreshed token was rejected too. The refresh itself
      // succeeded, so the session is alive (a revoked one gets 403 on
      // refresh) — this endpoint is refusing the user for another reason.
      // Surface the error; don't refresh again (that's how this would loop)
      // and don't log out.
      if (err.requestOptions.extra['isRetry'] == true) {
        return handler.next(err);
      }

      // Sent with a token that another request has since refreshed — retry
      // with the current one instead of refreshing a second time.
      final currentToken = tokenManager.getAccessToken();
      if (currentToken != null &&
          currentToken.isNotEmpty &&
          err.requestOptions.headers['Authorization'] !=
              'Bearer $currentToken') {
        return _retryWith(err.requestOptions, currentToken, handler);
      }

      final result = await tokenManager.refreshAccessToken();

      switch (result) {
        case RefreshResult.success:
          final newAccessToken = tokenManager.getAccessToken();
          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            return _retryWith(err.requestOptions, newAccessToken, handler);
          }
        case RefreshResult.rejected:
          // Refresh refused: 403 for a session revoked by a login on another
          // device, 401 for an expired refresh token.
          await getIt<SessionManager>().forceLogout(
            message: SessionManager.sessionExpiredMessage,
          );
        case RefreshResult.transientFailure:
          // Couldn't reach the refresh endpoint — the session may well be
          // fine. Surface this request's error, keep the user signed in.
          break;
      }
    }

    return handler.next(err);
  }

  /// Re-sends [options] once with [accessToken]. Retries on the shared,
  /// intercepted Dio instance (not a throwaway one) so the retried request
  /// still gets logging/error-mapping/cert-pinning. Safe from infinite
  /// recursion because `options` carries `extra['isRetry'] = true`, which
  /// [onError] checks on the next pass.
  Future<void> _retryWith(
    RequestOptions options,
    String accessToken,
    ErrorInterceptorHandler handler,
  ) async {
    options.extra['isRetry'] = true;
    options.headers['Authorization'] = 'Bearer $accessToken';
    try {
      final retryResponse = await _dio.fetch(options);
      return handler.resolve(retryResponse);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }

  bool _skipsSessionHandling(RequestOptions options) =>
      options.extra['skipSessionHandling'] == true;
}
