import 'package:injectable/injectable.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_profile_update_entity.dart';
import 'package:mint_talk/features/user_side/home/domain/repositories/host_repository.dart';

/// Live `profile_updated` pushes, so cached host cards pick up a new
/// `avatarUrl` without a refetch.
@injectable
class WatchHostProfileUpdatesUseCase {
  final HostRepository _repository;

  WatchHostProfileUpdatesUseCase(this._repository);

  Stream<HostProfileUpdateEntity> call() => _repository.watchProfileUpdates();
}
