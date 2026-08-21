import 'package:equatable/equatable.dart';
import 'notification_entity.dart';

class PaginatedNotificationsEntity extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final int unreadCount;
  final List<NotificationEntity> items;

  const PaginatedNotificationsEntity({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.unreadCount,
    required this.items,
  });

  @override
  List<Object?> get props => [page, limit, total, totalPages, unreadCount, items];
}
