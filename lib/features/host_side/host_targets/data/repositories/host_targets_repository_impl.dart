import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/dio_failure_mapper.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import '../datasources/host_targets_remote_data_source.dart';
import '../../domain/entities/host_target_entity.dart';
import '../../domain/repositories/host_targets_repository.dart';

@LazySingleton(as: HostTargetsRepository)
class HostTargetsRepositoryImpl implements HostTargetsRepository {
  final HostTargetsRemoteDataSource remoteDataSource;

  HostTargetsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<HostTargetEntity>>> getMyTargets() async {
    try {
      final models = await remoteDataSource.getMyTargets();
      return Right(models);
    } on DioException catch (e, stackTrace) {
      appLogger.e(
        'HostTargetsRepositoryImpl: request error loading targets: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(
        mapDioExceptionToFailure(e, fallbackMessage: 'Failed to load targets'),
      );
    } catch (e, stackTrace) {
      appLogger.e(
        'HostTargetsRepositoryImpl: unknown error loading targets: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
