import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/dio_failure_mapper.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/paginated_hosts_entity.dart';
import '../datasources/favorites_remote_data_source.dart';
import '../../domain/repositories/favorites_repository.dart';

@LazySingleton(as: FavoritesRepository)
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Unit>> addFavorite(String hostId) async {
    try {
      await remoteDataSource.addFavorite(hostId);
      return const Right(unit);
    } on DioException catch (e, stackTrace) {
      appLogger.e(
        'FavoritesRepositoryImpl: request error adding favorite: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to add favorite'));
    } catch (e, stackTrace) {
      appLogger.e(
        'FavoritesRepositoryImpl: unknown error adding favorite: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeFavorite(String hostId) async {
    try {
      await remoteDataSource.removeFavorite(hostId);
      return const Right(unit);
    } on DioException catch (e, stackTrace) {
      appLogger.e(
        'FavoritesRepositoryImpl: request error removing favorite: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to remove favorite'));
    } catch (e, stackTrace) {
      appLogger.e(
        'FavoritesRepositoryImpl: unknown error removing favorite: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedHostsEntity>> getFavoriteHosts({
    int? page,
    int? limit,
  }) async {
    try {
      final dto = await remoteDataSource.getFavoriteHosts(page: page, limit: limit);
      return Right(dto.toEntity());
    } on DioException catch (e, stackTrace) {
      appLogger.e(
        'FavoritesRepositoryImpl: request error loading favorites: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to load favorites'));
    } catch (e, stackTrace) {
      appLogger.e(
        'FavoritesRepositoryImpl: unknown error loading favorites: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
