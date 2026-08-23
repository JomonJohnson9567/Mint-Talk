import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/dio_failure_mapper.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/shared/system_config/data/datasources/system_config_remote_datasource.dart';
import 'package:mint_talk/features/shared/system_config/domain/entities/system_config_entity.dart';
import 'package:mint_talk/features/shared/system_config/domain/repositories/system_config_repository.dart';

@LazySingleton(as: SystemConfigRepository)
class SystemConfigRepositoryImpl implements SystemConfigRepository {
  final SystemConfigRemoteDataSource remoteDataSource;

  SystemConfigRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, SystemConfigEntity>> getSystemConfig() async {
    try {
      final result = await remoteDataSource.getSystemConfig();
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'System config request failed'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
