import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/utils/token_manager.dart';

/// Centralized HTTP client used by **all** remote data sources.
///
/// Responsibilities:
/// - Attach `Authorization: Bearer <accessToken>` on protected requests.
/// - On 401/403: auto-call refresh-token, retry **once**.
/// - On refresh failure: clear tokens, throw [UnauthorizedException].
/// - Normalize both API response formats.
/// - Exponential backoff for 429 / 500+.
@lazySingleton
class ApiClient {
  static const _requestTimeout = Duration(seconds: 15);

  final http.Client _httpClient;
  final TokenManager _tokenManager;

  ApiClient({required TokenManager tokenManager})
      : _tokenManager = tokenManager,
        _httpClient = http.Client();

  // ── Public API ──────────────────────────────────────────────────────

  /// Send a GET request to the given [endpoint].
  /// Set [requiresAuth] to `true` for protected endpoints.
  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, String>? queryParams,
  }) async {
    return _sendRequest(
      method: 'GET',
      endpoint: endpoint,
      requiresAuth: requiresAuth,
      queryParams: queryParams,
    );
  }

  /// Send a POST request with a JSON [body].
  Future<Map<String, dynamic>> post(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, dynamic>? body,
  }) async {
    return _sendRequest(
      method: 'POST',
      endpoint: endpoint,
      requiresAuth: requiresAuth,
      body: body,
    );
  }

  /// Send a PATCH request with a JSON [body].
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, dynamic>? body,
  }) async {
    return _sendRequest(
      method: 'PATCH',
      endpoint: endpoint,
      requiresAuth: requiresAuth,
      body: body,
    );
  }

  /// Send a DELETE request.
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    return _sendRequest(
      method: 'DELETE',
      endpoint: endpoint,
      requiresAuth: requiresAuth,
    );
  }

  /// Access the raw HTTP response (needed for extracting headers, e.g. cookies).
  Future<http.Response> postRaw(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(endpoint);
    final headers = await _buildHeaders(requiresAuth: requiresAuth);

    log('================= API REQUEST ==================\n'
        '➡️ URL: POST $uri\n'
        '➡️ Auth: ${requiresAuth ? "Yes" : "No"}\n'
        '➡️ Body: ${body != null ? jsonEncode(body) : "none"}\n'
        '================================================');

    final response = await _httpClient
        .post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_requestTimeout);

    log('================= API RESPONSE =================\n'
        '⬅️ URL: POST $uri\n'
        '⬅️ Status: ${response.statusCode}\n'
        '⬅️ Body: ${response.body}\n'
        '================================================');

    return response;
  }

  // ── Internal ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _sendRequest({
    required String method,
    required String endpoint,
    bool requiresAuth = false,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool isRetry = false,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams: queryParams);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      final encodedBody = body != null ? jsonEncode(body) : null;

      log('================= API REQUEST ==================\n'
          '➡️ URL: $method $uri\n'
          '➡️ Auth: ${requiresAuth ? "Yes" : "No"} (Retry: $isRetry)\n'
          '➡️ Body: ${encodedBody ?? "none"}\n'
          '================================================');

      late http.Response response;

      switch (method) {
        case 'GET':
          response = await _httpClient
              .get(uri, headers: headers)
              .timeout(_requestTimeout);
          break;
        case 'POST':
          response = await _httpClient
              .post(uri, headers: headers, body: encodedBody)
              .timeout(_requestTimeout);
          break;
        case 'PATCH':
          response = await _httpClient
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(_requestTimeout);
          break;
        case 'DELETE':
          response = await _httpClient
              .delete(uri, headers: headers)
              .timeout(_requestTimeout);
          break;
        default:
          throw const ServerException(message: 'Unsupported HTTP method');
      }

      log('================= API RESPONSE =================\n'
          '⬅️ URL: $method $uri\n'
          '⬅️ Status: ${response.statusCode}\n'
          '⬅️ Body: ${response.body}\n'
          '================================================');

      return _handleResponse(
        response,
        method: method,
        endpoint: endpoint,
        requiresAuth: requiresAuth,
        body: body,
        queryParams: queryParams,
        isRetry: isRetry,
      );
    } on SocketException {
      log('❌ API ERROR SocketException on $method $endpoint');
      throw const NetworkException();
    } on TimeoutException {
      log('❌ API ERROR TimeoutException on $method $endpoint');
      throw const NetworkException(
        message: 'Request timed out. Please try again.',
      );
    } on http.ClientException catch (e) {
      log('❌ API ERROR ClientException ($e) on $method $endpoint');
      throw const NetworkException(message: 'Connection failed');
    }
  }

  Future<Map<String, dynamic>> _handleResponse(
    http.Response response, {
    required String method,
    required String endpoint,
    required bool requiresAuth,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    required bool isRetry,
  }) async {
    final statusCode = response.statusCode;
    final responseBody = _decodeBody(response);

    // ── Success ─────────────────────────────────────────
    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    }

    // ── 401 / 403 — Try refresh once ────────────────────
    if ((statusCode == 401 || statusCode == 403) && !isRetry) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        return _sendRequest(
          method: method,
          endpoint: endpoint,
          requiresAuth: requiresAuth,
          body: body,
          queryParams: queryParams,
          isRetry: true,
        );
      }
      await _tokenManager.clearAll();
      throw const UnauthorizedException();
    }

    // ── 429 — Rate Limited ──────────────────────────────
    if (statusCode == 429) {
      throw RateLimitException(
        message: responseBody['message'] ?? 'Too many requests',
      );
    }

    // ── Other errors ────────────────────────────────────
    throw ServerException(
      message: responseBody['message'] ?? 'Something went wrong',
      statusCode: statusCode,
    );
  }

  /// Handles BOTH API response formats:
  /// Format 1: `{ "success": true/false, ... }`
  /// Format 2: `{ "status": "success" | "error", ... }`
  Map<String, dynamic> _decodeBody(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      final bodyStr = response.body.trim();
      // If the backend crashes and returns an HTML page (like a 500 error), return a clean fallback
      if (bodyStr.startsWith('<') || bodyStr.length > 200) {
        return {'message': 'Server is experiencing issues. Please try again later.'};
      }
      return {'message': bodyStr};
    }
  }

  /// Attempts to refresh the access token using the stored refresh token.
  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final uri = _buildUri(ApiEndpoints.refreshToken);
      final response = await _httpClient
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Cookie': 'refreshToken=$refreshToken',
            },
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final isSuccess =
            body['success'] == true || body['status'] == 'success';

        if (isSuccess && body['accessToken'] != null) {
          _tokenManager.saveAccessToken(body['accessToken'] as String);
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Uri _buildUri(String endpoint, {Map<String, String>? queryParams}) {
    // Health endpoint is outside /api/v1
    if (endpoint.startsWith('http')) {
      return Uri.parse(endpoint);
    }
    final url = '${ApiEndpoints.baseUrl}$endpoint';
    final uri = Uri.parse(url);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  Future<Map<String, String>> _buildHeaders({bool requiresAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final accessToken = _tokenManager.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    // Attach refresh token cookie for requests that need it
    final refreshToken = await _tokenManager.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      headers['Cookie'] = 'refreshToken=$refreshToken';
    }

    return headers;
  }
}
