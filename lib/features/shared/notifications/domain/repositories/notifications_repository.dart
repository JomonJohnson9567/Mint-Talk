import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../entities/notification_entity.dart';
import '../entities/paginated_notifications_entity.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, PaginatedNotificationsEntity>> getNotifications({
    int? page,
    int? limit,
  });
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, Unit>> markAsRead(String id);
  Future<Either<Failure, Unit>> markAllAsRead();

  /// Continuous stream of notifications pushed in real time via
  /// the `new_notification` socket event.
  Stream<NotificationEntity> watchNewNotifications();
}
