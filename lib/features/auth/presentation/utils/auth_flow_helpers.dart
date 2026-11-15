import 'package:mint_talk/core/errors/failures.dart';

class AuthFlowHelpers {
  AuthFlowHelpers._();

  static String normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String normalizeCountryCode(String countryCode) {
    final trimmed = countryCode.trim();
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isNotEmpty) {
      return '+$digitsOnly';
    }
    return trimmed.toUpperCase();
  }

  static const String _genericOtpError =
      'Something went wrong on our side. Please try again in a moment.';

  /// Turns a send/verify OTP failure into a short message safe to show users.
  static String otpFailureMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'No internet connection. Check your network and try again.';
    }
    if (failure is RateLimitFailure) {
      return 'Too many attempts. Please wait a minute and try again.';
    }
    if (failure is ServerFailure && (failure.statusCode ?? 0) >= 500) {
      return _genericOtpError;
    }
    // 4xx messages from the backend ("Invalid OTP", "OTP expired") are
    // already user-facing; anything that looks technical is not.
    return _isUserFacing(failure.message) ? failure.message : _genericOtpError;
  }

  static bool _isUserFacing(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty || trimmed.length > 120) return false;
    return !RegExp(
      r'exception|error:|statuscode|internal server|null',
      caseSensitive: false,
    ).hasMatch(trimmed);
  }
}
