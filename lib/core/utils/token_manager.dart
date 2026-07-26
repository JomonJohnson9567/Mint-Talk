import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';

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

  TokenManager() : _secureStorage = const FlutterSecureStorage();

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
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        return _accessToken;
      }
    }
    return null;
  }

  /// Attempts to refresh the access token using the stored refresh token.
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final response = await refreshDio.post(
        ApiEndpoints.refreshToken,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Cookie': 'refreshToken=$refreshToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map<String, dynamic>) {
          final isSuccess =
              body['success'] == true || body['status'] == 'success';
          if (isSuccess && body['accessToken'] != null) {
            saveAccessToken(body['accessToken'] as String);
            return true;
          }
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
