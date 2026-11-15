import 'package:injectable/injectable.dart';
import '../repositories/notifications_repository.dart';

/// Fires on every socket (re)connect, so the notification list can catch
/// up on pushes missed while offline.
@injectable
class WatchNotificationReconnectsUseCase {
  final NotificationsRepository _repository;

  WatchNotificationReconnectsUseCase(this._repository);

  Stream<void> call() => _repository.watchReconnects();
}
