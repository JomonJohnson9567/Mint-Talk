import 'package:equatable/equatable.dart';
import 'message_status.dart';

class ConversationLastMessageEntity extends Equatable {
  final String id;
  final String content;
  final MessageStatus status;
  final DateTime? createdAt;

  const ConversationLastMessageEntity({
    required this.id,
    required this.content,
    required this.status,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, content, status, createdAt];
}
