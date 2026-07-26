import 'package:injectable/injectable.dart';
import 'package:mint_talk/features/user_side/home/domain/repositories/host_repository.dart';

/// Closes the Socket.io presence connection.
///
/// Called on cubit [close()] and on user logout to stop receiving events
/// and allow the backend to mark the host as offline.
@injectable
class DisconnectHostPresenceUseCase {
  final HostRepository _repository;

  DisconnectHostPresenceUseCase(this._repository);

  void call() => _repository.disconnectPresence();
}
