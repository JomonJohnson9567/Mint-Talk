import 'package:injectable/injectable.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_presence_entity.dart';
import 'package:mint_talk/features/user_side/home/domain/repositories/host_repository.dart';

/// Returns the continuous [HostPresenceEntity] stream from the socket.
///
/// This stream carries both the initial host snapshot (sent as a burst on
/// connect) and all subsequent real-time patches — making it the single
/// source of truth for the user-side host grid.
@injectable
class WatchHostPresenceUseCase {
  final HostRepository _repository;

  WatchHostPresenceUseCase(this._repository);

  Stream<HostPresenceEntity> call() => _repository.watchPresenceUpdates();
}
