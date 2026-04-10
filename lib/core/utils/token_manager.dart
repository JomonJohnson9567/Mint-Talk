import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

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
}
