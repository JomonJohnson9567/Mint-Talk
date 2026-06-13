import 'package:equatable/equatable.dart';

class HostApplicationEntity extends Equatable {
  final String name;
  final String bio;
  final String phone;
  final String dob;

  const HostApplicationEntity({
    required this.name,
    required this.bio,
    required this.phone,
    required this.dob,
  });

  @override
  List<Object?> get props => [name, bio, phone, dob];
}
