import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/utils/app_logger.dart';

/// Outcome of [TokenManager.refreshAccessToken].
enum RefreshResult {
  /// A new access token was issued and saved.
  success,

  /// The backend refused the refresh token (401/403) or none is stored —
  /// the session is over and the user must log in again.
  rejected,

  /// Network/timeout/server error — the session may still be valid, so
  /// callers must not log the user out.
  transientFailure,
}

/// Manages access and refresh tokens.
///
/// - **accessToken**: stored in-memory only (never written to disk).
/// - **refreshToken**: stored in [FlutterSecureStorage] (survives app restart).
@lazySingleton
class TokenManager {
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _secureStorage;

  /// In-memory access token — cleared on app restart.
  String? _accessToken;

  /// De-dupes concurrent refresh attempts — see [refreshAccessToken].
  Future<RefreshResult>? _refreshInFlight;

  /// Builds the Dio used for the refresh call. A separate, interceptor-free
  /// instance so a failing refresh can never recurse back into
  /// AuthInterceptor; overridable so tests can stub the transport.
  @visibleForTesting
  Dio Function() refreshDioFactory = () => Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  TokenManager({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // ── Access Token (in-memory) ────────────────────────────────────────

  void saveAccessToken(String token) {
    _accessToken = token;
  }

  String? getAccessToken() => _accessToken;

  // ── Refresh Token (secure storage) ──────────────────────────────────

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  // ── Clear all tokens (logout) ────────────────────────────────────────

  Future<void> clearAll() async {
    _accessToken = null;
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// Quick check if user has a stored refresh token (used on app startup).
  Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.isNotEmpty;
  }

  /// Returns active access token, attempting refresh if missing but refresh token exists.
  Future<String?> getValidAccessToken() async {
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      return _accessToken;
    }
    if (await hasRefreshToken()) {
      final result = await refreshAccessToken();
      if (result == RefreshResult.success) {
        return _accessToken;
      }
    }
    return null;
  }

  /// Attempts to refresh the access token using the stored refresh token.
  ///
  /// Multiple call sites can race here (e.g. [AuthInterceptor] retrying a
  /// 401'd REST call at the same moment [PresenceSocketService] hits an
  /// auth-classified `connect_error`). Firing two concurrent requests at
  /// `/auth/refresh-token` risks the backend treating the second as a
  /// reuse/replay and invalidating the session it just issued — so callers
  /// that arrive while a refresh is already in progress piggyback on that
  /// same in-flight result instead of starting a new one.
  ///
  /// Only [RefreshResult.rejected] means the session is over; callers must
  /// treat [RefreshResult.transientFailure] as "try again later", never as
  /// a reason to log out.
  Future<RefreshResult> refreshAccessToken() {
    return _refreshInFlight ??= _performRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<RefreshResult> _performRefresh() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return RefreshResult.rejected;
      }

      final response = await refreshDioFactory().post(
        ApiEndpoints.refreshToken,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Cookie': 'refreshToken=$refreshToken',
          },
        ),
      );

      final body = response.data;
      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final isSuccess =
            body['success'] == true || body['status'] == 'success';
        final accessToken = body['accessToken'];
        if (isSuccess && accessToken is String && accessToken.isNotEmpty) {
          saveAccessToken(accessToken);
          // If the backend rotates the refresh token, keep the new one —
          // replaying the old one on the next refresh could be read as
          // reuse and rejected, logging the user out for no reason.
          final rotated =
              extractRefreshTokenFromSetCookie(
                response.headers['set-cookie'],
              ) ??
              extractRefreshTokenFromBody(body);
          if (rotated != null && rotated != refreshToken) {
            await saveRefreshToken(rotated);
          }
          return RefreshResult.success;
        }
      }
      // A 2xx without a usable token is a server-side problem, not proof
      // the session was revoked.
      return RefreshResult.transientFailure;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Revoked session → 403, invalid/expired refresh token → 401. Anything
      // else (no network, timeout, 5xx) must not end the session.
      if (status == 401 || status == 403) {
        // Logged so a forced logout can be traced: 401 means the refresh
        // token expired, 403 that the session was revoked.
        appLogger.w(
          '[TokenManager] Refresh rejected $status: ${e.response?.data}',
        );
        return RefreshResult.rejected;
      }
      return RefreshResult.transientFailure;
    } catch (_) {
      return RefreshResult.transientFailure;
    }
  }
}

/// Extracts the `refreshToken` value from a response's `Set-Cookie` headers.
///
/// A response can carry more than one Set-Cookie header (refresh token
/// alongside a session/CSRF cookie, etc.), and a single header may join
/// several cookies with commas, so every entry is checked.
String? extractRefreshTokenFromSetCookie(List<String>? setCookieHeaders) {
  if (setCookieHeaders == null) return null;
  for (final header in setCookieHeaders) {
    // Cookie format: refreshToken=<value>; Path=/; HttpOnly; ...
    for (final cookie in header.split(',')) {
      final trimmed = cookie.trim();
      if (trimmed.startsWith('refreshToken=')) {
        final value = trimmed
            .split(';')
            .first
            .substring('refreshToken='.length);
        if (value.isNotEmpty) return value;
      }
    }
  }
  return null;
}

/// Reads a `refreshToken` the backend returns in a JSON body, for when it
/// sends the token there instead of (or as well as) a Set-Cookie header.
String? extractRefreshTokenFromBody(Object? body) {
  if (body is! Map) return null;
  final value = body['refreshToken'];
  return value is String && value.isNotEmpty ? value : null;
}
