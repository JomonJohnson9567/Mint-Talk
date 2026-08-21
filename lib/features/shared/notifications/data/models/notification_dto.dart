import '../../domain/entities/notification_entity.dart';

class NotificationDto extends NotificationEntity {
  const NotificationDto({
    required super.id,
    required super.userId,
    required super.title,
    required super.message,
    required super.type,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
