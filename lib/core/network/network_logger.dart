import 'dart:convert';
import 'dart:developer';

/// A dedicated logger for network requests and responses.
/// Helps keep the [ApiClient] clean and focused.
class NetworkLogger {
  static void logRequest({
    required String method,
    required Uri uri,
    required bool requiresAuth,
    required dynamic body,
    bool isRetry = false,
  }) {
    log('================= API REQUEST ==================\n'
        '➡️ URL: $method $uri\n'
        '➡️ Auth: ${requiresAuth ? "Yes" : "No"}${isRetry ? " (Retry)" : ""}\n'
        '➡️ Body: ${body != null ? jsonEncode(body) : "none"}\n'
        '================================================');
  }

  static void logResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required String body,
  }) {
    log('================= API RESPONSE =================\n'
        '⬅️ URL: $method $uri\n'
        '⬅️ Status: $statusCode\n'
        '⬅️ Body: $body\n'
        '================================================');
  }

  static void logError(String type, String method, String endpoint, [Object? error]) {
    log('❌ API ERROR $type on $method $endpoint${error != null ? " ($error)" : ""}');
  }
}
