import '../../domain/entities/paginated_notifications_entity.dart';
import 'notification_dto.dart';

class PaginatedNotificationsDto {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final int unreadCount;
  final List<NotificationDto> items;

  const PaginatedNotificationsDto({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.unreadCount,
    required this.items,
  });

  factory PaginatedNotificationsDto.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>? ?? const {});
    final rawList = (data['notifications'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(NotificationDto.fromJson)
        .toList();

    return PaginatedNotificationsDto(
      page: data['page'] as int? ?? 1,
      limit: data['limit'] as int? ?? rawList.length,
      total: data['total'] as int? ?? rawList.length,
      totalPages: data['totalPages'] as int? ?? 1,
      unreadCount: data['unreadCount'] as int? ?? 0,
      items: rawList,
    );
  }

  PaginatedNotificationsEntity toEntity() {
    return PaginatedNotificationsEntity(
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
      unreadCount: unreadCount,
      items: items,
    );
  }
}
