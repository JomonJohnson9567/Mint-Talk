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
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to fetch hosts'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ── Socket presence (primary data source for user home) ──────────────────

  @override
  Stream<HostPresenceEntity> watchPresenceUpdates() =>
      _presenceSocketService.presenceUpdates;

  @override
  void connectPresence(String accessToken) =>
      _presenceSocketService.connect(accessToken);

  @override
  void disconnectPresence() => _presenceSocketService.disconnect();
}

