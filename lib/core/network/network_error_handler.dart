import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mint_talk/core/errors/exceptions.dart';

/// Standardizes error handling and response decoding across the application.
class NetworkErrorHandler {
  /// Decodes response body and handles common HTML error fallbacks.
  static Map<String, dynamic> decodeBody(http.Response response) {
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

  /// Parses error messages from the response body based on multiple API formats.
  static Map<String, String> parseErrors(dynamic response) {
    if (response is! Map) return {};

    final errors = response['errors'];
    if (errors is Map) {
      return Map<String, String>.from(
        errors.map((key, value) => MapEntry(key.toString(), value.toString())),
      );
    }

    // fallback (common patterns)
    final message = response['message'];
    if (message is String) {
      return {"general": message};
    }

    return {"general": "Something went wrong"};
  }

  /// Throws standard exceptions based on status code and response body.
  static void handleError(int statusCode, Map<String, dynamic> responseBody) {
    if (statusCode == 429) {
      throw RateLimitException(
        message: responseBody['message'] ?? 'Too many requests',
      );
    }

    throw ServerException(
      message: responseBody['message'] ?? 'Something went wrong',
      statusCode: statusCode,
    );
  }
}
