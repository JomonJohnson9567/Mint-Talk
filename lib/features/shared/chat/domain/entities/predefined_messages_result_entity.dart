import 'package:equatable/equatable.dart';
import 'predefined_message_entity.dart';

class PredefinedMessagesResultEntity extends Equatable {
  final String role;
  final List<PredefinedMessageEntity> messages;

  const PredefinedMessagesResultEntity({
    required this.role,
    required this.messages,
  });

  @override
  List<Object?> get props => [role, messages];
}
