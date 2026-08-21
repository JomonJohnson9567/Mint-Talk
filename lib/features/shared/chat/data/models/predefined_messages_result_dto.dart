import '../../domain/entities/predefined_messages_result_entity.dart';
import 'predefined_message_dto.dart';

class PredefinedMessagesResultDto {
  final String role;
  final List<PredefinedMessageDto> messages;

  const PredefinedMessagesResultDto({
    required this.role,
    required this.messages,
  });

  factory PredefinedMessagesResultDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final rawList = (data['messages'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(PredefinedMessageDto.fromJson)
        .toList();

    return PredefinedMessagesResultDto(
      role: (data['role'] ?? '').toString(),
      messages: rawList,
    );
  }

  PredefinedMessagesResultEntity toEntity() {
    final sorted = messages.map((m) => m.toEntity()).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return PredefinedMessagesResultEntity(role: role, messages: sorted);
  }
}
