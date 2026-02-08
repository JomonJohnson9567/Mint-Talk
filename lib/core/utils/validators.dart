import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class Validators {
  Validators._();

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? phone(String? value, {required String countryCode}) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phone = value.trim();
    try {
      if (phone.startsWith('+')) {
        final parsed = PhoneNumber.parse(phone);
        if (!parsed.isValid()) return 'Enter a valid phone number';
      } else {
        final iso = IsoCode.values.byName(countryCode);
        final parsed = PhoneNumber.parse(phone, destinationCountry: iso);
        if (!parsed.isValid()) return 'Enter a valid phone number';
      }
    } catch (_) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }
    final otp = value.trim();
    if (!RegExp(r'^[0-9]{5}$').hasMatch(otp)) {
      return 'Enter a valid 5-digit OTP';
    }
    return null;
  }
}
