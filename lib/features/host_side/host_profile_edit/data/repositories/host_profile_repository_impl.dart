import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../domain/entities/host_profile_entity.dart';
import '../../domain/repositories/host_profile_repository.dart';
import '../datasources/host_profile_remote_datasource.dart';
import '../models/host_profile_model.dart';

@LazySingleton(as: HostProfileRepository)
class HostProfileRepositoryImpl implements HostProfileRepository {
  final HostProfileRemoteDataSource remoteDataSource;

  HostProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, HostProfileEntity>> getHostProfile() async {
    try {
      final model = await remoteDataSource.getHostProfile();
      return Right(model);
    } catch (e, stackTrace) {
      appLogger.e('HostProfileRepositoryImpl: Error fetching profile: $e', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateHostProfile(HostProfileEntity profile) async {
    try {
      final model = HostProfileModel.fromEntity(profile);
      final success = await remoteDataSource.updateHostProfile(model);
      return Right(success);
    } catch (e, stackTrace) {
      appLogger.e('HostProfileRepositoryImpl: Error updating profile: $e', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
