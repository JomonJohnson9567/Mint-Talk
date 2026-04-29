import 'package:mint_talk/core/errors/exceptions.dart';

class DateOfBirth {
  final String value;
  final DateTime date;

  DateOfBirth(String input) : value = input.trim(), date = _parse(input) {
    _validate(date);
  }

  static DateTime _parse(String input) {
    try {
      final parts = input.split('/');
      if (parts.length != 3) throw const FormatException();
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } catch (_) {
      throw const ValidationException({'dob': 'Invalid date format'});
    }
  }

  void _validate(DateTime dobDate) {
    final today = DateTime.now();
    int age = today.year - dobDate.year;
    if (today.month < dobDate.month ||
        (today.month == dobDate.month && today.day < dobDate.day)) {
      age--;
    }

    if (age < 18) {
      throw const ValidationException({'dob': 'You must be at least 18 years old'});
    }
  }

  @override
  String toString() => value;
}
