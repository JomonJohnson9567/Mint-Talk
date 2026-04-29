import 'package:mint_talk/core/errors/exceptions.dart';

class ReferralCodeValue {
  final String? value;

  ReferralCodeValue(String? input) : value = _validate(input);

  static String? _validate(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    
    final value = input.trim();
    final regex = RegExp(r'^[A-Z0-9-]{4,15}$');
    if (!regex.hasMatch(value)) {
      throw const ValidationException({'referralCode': 'Invalid referral code format'});
    }
    return value;
  }

  @override
  String toString() => value ?? '';
}
