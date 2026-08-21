import 'package:injectable/injectable.dart';
import '../entities/notification_entity.dart';
import '../repositories/notifications_repository.dart';

/// Continuous stream of notifications pushed via the `new_notification`
/// socket event — the live-update source for the unread badge and list.
@injectable
class WatchNewNotificationsUseCase {
  final NotificationsRepository _repository;

  WatchNewNotificationsUseCase(this._repository);

  Stream<NotificationEntity> call() => _repository.watchNewNotifications();
}
