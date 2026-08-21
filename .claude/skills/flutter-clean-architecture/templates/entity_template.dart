import 'package:equatable/equatable.dart';

/// Pure Dart domain entity — no json, no Flutter, no annotations.
/// Rename `User` and fields for your feature.
class User extends Equatable {
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [id, name, email];
}
