import 'package:equatable/equatable.dart';

class CallParticipantEntity extends Equatable {
  final String id;
  final String fullName;
  final String phone;
  final String role;
  final String avatarUrl;

  const CallParticipantEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, fullName, phone, role, avatarUrl];
}
