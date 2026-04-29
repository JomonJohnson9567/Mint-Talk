import 'package:mint_talk/core/errors/exceptions.dart';

class FullName {
  final String value;

  FullName(String input) : value = input.trim() {
    final Map<String, String> errors = {};
    
    if (value.isEmpty) {
      errors['fullName'] = 'Name is required';
    } else if (value.length < 5) {
      errors['fullName'] = 'Name must be at least 5 characters';
    } else if (value.length > 50) {
      errors['fullName'] = 'Name must not exceed 50 characters';
    }

    if (errors.isNotEmpty) {
      throw ValidationException(errors);
    }
  }

  @override
  String toString() => value;
}
