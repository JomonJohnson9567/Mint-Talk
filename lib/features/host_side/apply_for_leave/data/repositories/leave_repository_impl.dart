import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/data/datasources/leave_remote_datasource.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/data/models/leave_request_model.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/domain/entities/leave_request_entity.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/domain/entities/leave_history_entity.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/domain/repositories/leave_repository.dart';

import 'package:mint_talk/core/errors/dio_failure_mapper.dart';

@LazySingleton(as: LeaveRepository)
class LeaveRepositoryImpl implements LeaveRepository {
  final LeaveRemoteDataSource remoteDataSource;

  LeaveRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Unit>> applyForLeave(LeaveRequestEntity request) async {
    try {
      final model = LeaveRequestModel.fromEntity(request);
      await remoteDataSource.applyForLeave(model);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to apply for leave'));
    } catch (e, stackTrace) {
      appLogger.e(
        'LeaveRepositoryImpl: Error applying for leave: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getAvailableDays() async {
    try {
      final days = await remoteDataSource.getAvailableDays();
      return Right(days);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to get available leave days'));
    } catch (e, stackTrace) {
      appLogger.e(
        'LeaveRepositoryImpl: Error getting available days: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LeaveHistoryPageEntity>> getLeaveHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final history = await remoteDataSource.getLeaveHistory(page: page, limit: limit);
      return Right(history);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to get leave history'));
    } catch (e, stackTrace) {
      appLogger.e(
        'LeaveRepositoryImpl: Error getting leave history: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
