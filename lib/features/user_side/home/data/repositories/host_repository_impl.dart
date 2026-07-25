import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/paginated_hosts_entity.dart';
import '../../domain/repositories/host_repository.dart';
import '../datasources/host_remote_data_source.dart';

@LazySingleton(as: HostRepository)
class HostRepositoryImpl implements HostRepository {
  final HostRemoteDataSource remoteDataSource;

  HostRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PaginatedHostsEntity>> getOnlineHosts({
    int? page,
    int? limit,
  }) async {
    return _fetchHosts(
      () => remoteDataSource.getOnlineHosts(page: page, limit: limit),
    );
  }

  @override
  Future<Either<Failure, PaginatedHostsEntity>> getOnCallHosts({
    int? page,
    int? limit,
  }) async {
    return _fetchHosts(
      () => remoteDataSource.getOnCallHosts(page: page, limit: limit),
    );
  }

  Future<Either<Failure, PaginatedHostsEntity>> _fetchHosts(
    Future<dynamic> Function() call,
  ) async {
    try {
      final dto = await call();
      return Right(dto.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
