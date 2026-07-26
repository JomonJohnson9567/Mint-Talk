import 'package:equatable/equatable.dart';

class HostApplicationEntity extends Equatable {
  final String name;
  final String dob;
  final String bio;
  final String selfieUrl;

  const HostApplicationEntity({
    required this.name,
    required this.dob,
    required this.bio,
    required this.selfieUrl,
  });

  @override
  List<Object?> get props => [name, dob, bio, selfieUrl];
}
