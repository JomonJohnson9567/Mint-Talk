import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import '../../domain/entities/host_dashboard_data_entity.dart';
import '../../domain/entities/host_preferences_entity.dart';
import '../../domain/repositories/host_dash_repository.dart';
import '../datasources/host_dash_remote_datasource.dart';
import '../models/host_preferences_model.dart';

@LazySingleton(as: HostDashRepository)
class HostDashRepositoryImpl implements HostDashRepository {
  final HostDashRemoteDataSource remoteDataSource;

  HostDashRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, HostDashboardDataEntity>> getDashboardData() async {
    try {
      final model = await remoteDataSource.getDashboardData();
      return Right(model);
    } catch (e, stackTrace) {
      appLogger.e(
        'HostDashRepositoryImpl: Error getting dashboard data: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, HostPreferencesEntity>> updatePreferences(
    HostPreferencesEntity preferences,
  ) async {
    try {
      final model = HostPreferencesModel.fromEntity(preferences);
      final updatedPreferences = await remoteDataSource.updatePreferences(
        model,
      );
      return Right(updatedPreferences);
    } on DioException catch (e, stackTrace) {
      final error = e.error;
      appLogger.e(
        'HostDashRepositoryImpl: Error updating host preferences: $e',
        error: e,
        stackTrace: stackTrace,
      );
      if (error is UnauthorizedException) {
        return Left(UnauthorizedFailure(message: error.message));
      }
      return Left(ServerFailure(message: e.message ?? 'Request failed'));
    } catch (e, stackTrace) {
      appLogger.e(
        'HostDashRepositoryImpl: Error updating host preferences: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
