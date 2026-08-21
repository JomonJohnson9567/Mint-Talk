import '../../domain/entities/predefined_message_entity.dart';

class PredefinedMessageDto {
  final String id;
  final String text;
  final String targetRole;
  final String category;
  final int order;
  final bool isActive;

  const PredefinedMessageDto({
    required this.id,
    required this.text,
    required this.targetRole,
    required this.category,
    required this.order,
    required this.isActive,
  });

  factory PredefinedMessageDto.fromJson(Map<String, dynamic> json) {
    return PredefinedMessageDto(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      targetRole: (json['targetRole'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      order: int.tryParse(json['order']?.toString() ?? '') ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  PredefinedMessageEntity toEntity() {
    return PredefinedMessageEntity(
      id: id,
      text: text,
      targetRole: targetRole,
      category: category,
      order: order,
      isActive: isActive,
    );
  }
}
