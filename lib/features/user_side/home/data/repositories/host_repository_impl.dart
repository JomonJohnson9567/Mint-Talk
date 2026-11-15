import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/dio_failure_mapper.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/services/socket/i_presence_socket_service.dart';
import '../../domain/entities/host_presence_entity.dart';
import '../../domain/entities/paginated_hosts_entity.dart';
import '../../domain/repositories/host_repository.dart';
import '../datasources/host_remote_data_source.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_profile_update_entity.dart';

@LazySingleton(as: HostRepository)
class HostRepositoryImpl implements HostRepository {
  final HostRemoteDataSource _remoteDataSource;
  final IPresenceSocketService _presenceSocketService;

  HostRepositoryImpl(this._remoteDataSource, this._presenceSocketService);

  // ── REST (kept for future use) ────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedHostsEntity>> getOnlineHosts({
    int? page,
    int? limit,
  }) async {
    return _fetchHosts(
      () => _remoteDataSource.getOnlineHosts(page: page, limit: limit),
    );
  }

  @override
  Future<Either<Failure, PaginatedHostsEntity>> getOnCallHosts({
    int? page,
    int? limit,
  }) async {
    return _fetchHosts(
      () => _remoteDataSource.getOnCallHosts(page: page, limit: limit),
    );
  }

  @override
  Future<Either<Failure, PaginatedHostsEntity>> getAllHosts({
    int? page,
    int? limit,
  }) async {
    return _fetchHosts(
      () => _remoteDataSource.getAllHosts(page: page, limit: limit),
    );
  }

  Future<Either<Failure, PaginatedHostsEntity>> _fetchHosts(
    Future<dynamic> Function() call,
  ) async {
    try {
      final dto = await call();
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(
        mapDioExceptionToFailure(e, fallbackMessage: 'Failed to fetch hosts'),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ── Socket presence (primary data source for user home) ──────────────────

  @override
  Stream<HostPresenceEntity> watchPresenceUpdates() =>
      _presenceSocketService.presenceUpdates;

  @override
  Stream<HostProfileUpdateEntity> watchProfileUpdates() => _presenceSocketService
      .profileUpdates
      .map(_toProfileUpdate)
      .where((update) => update != null)
      .cast<HostProfileUpdateEntity>();

  /// Accepts a flat payload or one nested under `user`/`profile`/`data`.
  static HostProfileUpdateEntity? _toProfileUpdate(Map<String, dynamic> data) {
    final nested = data['user'] ?? data['profile'] ?? data['data'];
    final json = nested is Map ? Map<String, dynamic>.from(nested) : data;
    final id =
        (json['userId'] ?? json['_id'] ?? json['id'] ?? data['userId'])
            ?.toString() ??
        '';
    if (id.isEmpty) return null;
    String? text(Object? value) {
      final s = value?.toString().trim() ?? '';
      return s.isEmpty ? null : s;
    }

    return HostProfileUpdateEntity(
      userId: id,
      avatarUrl: text(json['avatarUrl']),
      fullName: text(json['fullName']),
    );
  }

  @override
  void connectPresence(String accessToken) =>
      _presenceSocketService.connect(accessToken);

  @override
  void disconnectPresence() => _presenceSocketService.disconnect();
}
