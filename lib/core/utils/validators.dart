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
    if (!RegExp(r'^[0-9]{4}$').hasMatch(otp)) {
      return 'Enter a valid 4-digit OTP';
    }
    return null;
  }

  static String? dob(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date of birth is required';
    }

    try {
      // Expecting format: d/M/yyyy
      final parts = value.split('/');
      if (parts.length != 3) {
        return 'Invalid date format';
      }

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final dobDate = DateTime(year, month, day);
      final today = DateTime.now();

      int age = today.year - dobDate.year;
      if (today.month < dobDate.month ||
          (today.month == dobDate.month && today.day < dobDate.day)) {
        age--;
      }

      const int minAge = 18;
      if (age < minAge) {
        return 'You must be at least 18 years old';
      }
    } catch (_) {
      return 'Invalid date format';
    }

    return null;
  }

  static String? gender(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a gender';
    }
    return null;
  }
}
