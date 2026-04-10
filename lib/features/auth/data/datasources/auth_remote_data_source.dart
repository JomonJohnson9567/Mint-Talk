import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mint_talk/features/auth/data/models/user_model.dart';
import 'package:mint_talk/features/auth/domain/entities/auth_response_entity.dart';

/// Remote data source for auth-related API calls.
@lazySingleton
class AuthRemoteDataSource {
  final ApiClient _apiClient;
  final TokenManager _tokenManager;

  const AuthRemoteDataSource(this._apiClient, this._tokenManager);

  /// POST /auth/send-otp
  ///
  /// Sends an OTP to the given phone number.
  Future<void> sendOtp({
    required String phone,
    required String countryCode,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.sendOtp,
      body: {'phone': phone, 'countryCode': countryCode},
    );

    final isSuccess =
        response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(
        message: response['message'] as String? ?? 'Failed to send OTP',
      );
    }
  }

  /// POST /auth/verify-otp
  ///
  /// Verifies the OTP and returns user + access token.
  /// Also extracts the `Set-Cookie` header to store the refresh token.
  Future<AuthResponseEntity> verifyOtp({
    required String phone,
    required String countryCode,
    required String otp,
  }) async {
    // Use postRaw to access response headers for cookie extraction
    final response = await _apiClient.postRaw(
      ApiEndpoints.verifyOtp,
      body: {'phone': phone, 'countryCode': countryCode, 'otp': otp},
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    // Check response status code
    if (response.statusCode == 429) {
      throw RateLimitException(
        message: body['message'] as String? ?? 'Too many requests',
      );
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerException(
        message: body['message'] as String? ?? 'OTP verification failed',
        statusCode: response.statusCode,
      );
    }

    final isSuccess = body['success'] == true || body['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(
        message: body['message'] as String? ?? 'OTP verification failed',
      );
    }

    // ── Extract refresh token from Set-Cookie header ──────────────────
    final setCookieHeader = response.headers['set-cookie'];
    if (setCookieHeader != null) {
      final refreshToken = _extractRefreshToken(setCookieHeader);
      if (refreshToken != null) {
        await _tokenManager.saveRefreshToken(refreshToken);
      }
    }

    // ── Parse user and access token ───────────────────────────────────
    final userJson = body['user'] as Map<String, dynamic>;
    final accessToken = body['accessToken'] as String;

    _tokenManager.saveAccessToken(accessToken);

    final user = UserModel.fromJson(userJson);

    return AuthResponseEntity(user: user, accessToken: accessToken);
  }

  /// Extracts the `refreshToken` value from a `Set-Cookie` header string.
  String? _extractRefreshToken(String setCookieHeader) {
    // Cookie format: refreshToken=<value>; Path=/; HttpOnly; ...
    final cookies = setCookieHeader.split(',');
    for (final cookie in cookies) {
      final trimmed = cookie.trim();
      if (trimmed.startsWith('refreshToken=')) {
        final value = trimmed.split(';').first;
        return value.substring('refreshToken='.length);
      }
    }
    return null;
  }
}
