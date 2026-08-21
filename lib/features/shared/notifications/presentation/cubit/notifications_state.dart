import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/shared/notifications/domain/entities/notification_entity.dart';

enum NotificationsStatus { initial, loading, loaded, loadingMore, failure }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final int page;
  final int totalPages;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.page = 1,
    this.totalPages = 1,
    this.errorMessage,
  });

  bool get isLoading =>
      status == NotificationsStatus.initial || status == NotificationsStatus.loading;

  bool get hasMore => page < totalPages;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? notifications,
    int? unreadCount,
    int? page,
    int? totalPages,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        unreadCount,
        page,
        totalPages,
        errorMessage,
      ];
}
