import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mint_talk/features/auth/data/models/user_model.dart';
import 'package:mint_talk/features/auth/domain/entities/auth_response_entity.dart';


/// Remote data source for auth-related API calls.
abstract class IAuthRemoteDataSource {
  Future<void> sendOtp({required String phone, required String countryCode});

  Future<AuthResponseEntity> verifyOtp({
    required String phone,
    required String countryCode,
    required String otp,
  });

  Future<void> logout();
}

@LazySingleton(as: IAuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final TokenManager _tokenManager;

  const AuthRemoteDataSourceImpl(this._apiClient, this._tokenManager);

  /// POST /auth/send-otp (MUTED FOR TESTING)
  ///
  /// Sends an OTP to the given phone number.
  @override
  Future<void> sendOtp({
    required String phone,
    required String countryCode,
  }) async {
    // Muted for testing purposes: return immediately without calling backend API.
    return;
  }

  /// POST /auth/verify-otp
  ///
  /// Verifies the OTP and returns user + access token.
  /// Also extracts the `Set-Cookie` header to store the refresh token.
  @override
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

    final body = response.data as Map<String, dynamic>;

    appLogger.d('[AuthRemoteDataSource] verifyOtp response received');

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
    final setCookieHeader = response.headers.value('set-cookie');
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

  /// POST /auth/logout
  ///
  /// Invalidates current session on backend.
  /// Success is accepted for 200 / 204 paths handled by [ApiClient].
  @override
  Future<void> logout() async {
    final response = await _apiClient.post(
      ApiEndpoints.logout,
      requiresAuth: true,
    );

    // For 204, body may be empty and still valid. Only reject explicit failure payloads.
    final isExplicitFailure =
        response['success'] == false || response['status'] == 'error';
    if (isExplicitFailure) {
      throw ServerException(
        message: response['message'] as String? ?? 'Failed to logout',
      );
    }
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
