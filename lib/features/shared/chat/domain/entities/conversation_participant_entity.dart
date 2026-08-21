import 'package:equatable/equatable.dart';

class ConversationParticipantEntity extends Equatable {
  final String id;
  final String fullName;
  final String avatarUrl;
  final String role;

  const ConversationParticipantEntity({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
    required this.role,
  });

  @override
  List<Object?> get props => [id, fullName, avatarUrl, role];
}
