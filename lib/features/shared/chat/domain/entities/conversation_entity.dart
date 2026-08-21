import 'package:equatable/equatable.dart';
import 'conversation_last_message_entity.dart';
import 'conversation_participant_entity.dart';

class ConversationEntity extends Equatable {
  final String id;
  final List<ConversationParticipantEntity> participants;
  final Map<String, int> unreadCounts;
  final ConversationLastMessageEntity? lastMessage;
  final DateTime? lastMessageAt;

  const ConversationEntity({
    required this.id,
    required this.participants,
    required this.unreadCounts,
    this.lastMessage,
    this.lastMessageAt,
  });

  ConversationParticipantEntity otherParticipant(String myUserId) {
    return participants.firstWhere(
      (p) => p.id != myUserId,
      orElse: () => participants.first,
    );
  }

  int unreadCountFor(String myUserId) => unreadCounts[myUserId] ?? 0;

  @override
  List<Object?> get props => [
    id,
    participants,
    unreadCounts,
    lastMessage,
    lastMessageAt,
  ];
}
