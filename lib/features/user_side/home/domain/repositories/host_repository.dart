import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/host_presence_entity.dart';
import '../entities/paginated_hosts_entity.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_profile_update_entity.dart';

abstract class HostRepository {
  // ── REST (kept for future use) ────────────────────────────────────────────

  Future<Either<Failure, PaginatedHostsEntity>> getOnlineHosts({
    int? page,
    int? limit,
  });

  Future<Either<Failure, PaginatedHostsEntity>> getOnCallHosts({
    int? page,
    int? limit,
  });

  Future<Either<Failure, PaginatedHostsEntity>> getAllHosts({
    int? page,
    int? limit,
  });

  // ── Socket presence (primary data source for user home) ──────────────────

  /// Continuous stream of host presence events.
  ///
  /// Emits:
  /// - An initial burst sent by the server immediately on connect
  ///   (full presence snapshot, one event per online host).
  /// - Real-time patches whenever any host status changes.
  Stream<HostPresenceEntity> watchPresenceUpdates();

  /// `profile_updated` pushes (avatar/name changes) for any user.
  Stream<HostProfileUpdateEntity> watchProfileUpdates();

  /// Opens the socket connection authenticated with [accessToken].
  void connectPresence(String accessToken);

  /// Closes the socket connection gracefully.
  void disconnectPresence();
}
