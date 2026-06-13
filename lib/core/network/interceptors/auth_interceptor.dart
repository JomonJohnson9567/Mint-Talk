import 'package:dio/dio.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokenManager = getIt<TokenManager>();

    // 1. Attach Access Token as Bearer Header
    final accessToken = tokenManager.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // 2. Attach Refresh Token as Cookie Header (for manual cookie management)
    final refreshToken = await tokenManager.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      options.headers['Cookie'] = 'refreshToken=$refreshToken';
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

    // Handle 401 / 403 Unauthorized errors
    if (statusCode == 401 || statusCode == 403) {
      final tokenManager = getIt<TokenManager>();

      // Avoid infinite loop if the refresh attempt itself or the retried request fails again
      if (err.requestOptions.extra['isRetry'] == true) {
        await tokenManager.clearAll();
        return handler.next(err);
      }

      final refreshed = await _tryRefreshToken(tokenManager);

      if (refreshed) {
        final options = err.requestOptions;
        options.extra['isRetry'] = true;

        // Apply new credentials
        final newAccessToken = tokenManager.getAccessToken();
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $newAccessToken';
        }

        try {
          // Send request again with a new, clean Dio instance
          final retryDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
          final retryResponse = await retryDio.request(
            options.path,
            data: options.data,
            queryParameters: options.queryParameters,
            options: Options(
              method: options.method,
              headers: options.headers,
            ),
          );
          return handler.resolve(retryResponse);
        } on DioException catch (retryErr) {
          return handler.next(retryErr);
        }
      } else {
        await tokenManager.clearAll();
        // Redirect to login screen on session expiry
        getIt<NavigationService>().navigateAndRemoveUntil(AppRoutes.phoneNumber);
      }
    }

    return handler.next(err);
  }

  Future<bool> _tryRefreshToken(TokenManager tokenManager) async {
    try {
      final refreshToken = await tokenManager.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

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
          final isSuccess = body['success'] == true || body['status'] == 'success';
          if (isSuccess && body['accessToken'] != null) {
            tokenManager.saveAccessToken(body['accessToken'] as String);
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
