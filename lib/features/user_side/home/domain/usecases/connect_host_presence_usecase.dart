import 'package:injectable/injectable.dart';
import 'package:mint_talk/features/user_side/home/domain/repositories/host_repository.dart';

/// Opens the Socket.io presence connection with the provided [accessToken].
///
/// Must be called once on cubit initialization, before subscribing to
/// [WatchHostPresenceUseCase].
@injectable
class ConnectHostPresenceUseCase {
  final HostRepository _repository;

  ConnectHostPresenceUseCase(this._repository);

  void call(String accessToken) => _repository.connectPresence(accessToken);
}
