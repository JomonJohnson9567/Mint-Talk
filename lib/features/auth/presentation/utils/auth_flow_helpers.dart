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

  static String otpFailureMessage(Failure failure) {
    if (failure is ServerFailure && (failure.statusCode ?? 0) >= 500) {
      return 'OTP service is unavailable right now. Please try again in a moment.';
    }
    return failure.message;
  }
}
