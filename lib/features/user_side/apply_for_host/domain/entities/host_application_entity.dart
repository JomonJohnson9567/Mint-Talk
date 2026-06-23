import 'package:equatable/equatable.dart';

class HostApplicationEntity extends Equatable {
  final String name;
  final String bio;
  final String phone;
  final String dob;
  final String aadhaarNumber;
  final String aadhaarFront;
  final String aadhaarBack;
  final String selfie;

  const HostApplicationEntity({
    required this.name,
    required this.bio,
    required this.phone,
    required this.dob,
    required this.aadhaarNumber,
    required this.aadhaarFront,
    required this.aadhaarBack,
    required this.selfie,
  });

  @override
  List<Object?> get props => [
        name,
        bio,
        phone,
        dob,
        aadhaarNumber,
        aadhaarFront,
        aadhaarBack,
        selfie,
      ];
}
