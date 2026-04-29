import 'package:mint_talk/core/errors/exceptions.dart';

enum Gender { male, female, other }

class GenderValue {
  final Gender value;

  GenderValue(String input) : value = _parse(input);

  static Gender _parse(String input) {
    if (input.isEmpty) {
      throw const ValidationException({'gender': 'Please select a gender'});
    }
    
    try {
      return Gender.values.byName(input.toLowerCase());
    } catch (_) {
      throw const ValidationException({'gender': 'Invalid gender selection'});
    }
  }

  @override
  String toString() => value.name;
}
