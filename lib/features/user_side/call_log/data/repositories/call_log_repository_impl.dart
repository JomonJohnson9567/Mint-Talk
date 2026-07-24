import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/call_log_entity.dart';
import '../../domain/entities/call_statistics_report_entity.dart';
import '../../domain/repositories/call_log_repository.dart';
import '../datasources/call_log_remote_data_source.dart';

@LazySingleton(as: CallLogRepository)
class CallLogRepositoryImpl implements CallLogRepository {
  final CallLogRemoteDataSource remoteDataSource;

  CallLogRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<CallLogEntity>>> getUserCallLogs({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final dtos = await remoteDataSource.getUserCallLogs(
        status: status,
        page: page,
        limit: limit,
      );
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CallLogEntity>>> getHostCallLogs({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final dtos = await remoteDataSource.getHostCallLogs(
        status: status,
        page: page,
        limit: limit,
      );
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CallStatisticsReportEntity>> getCallStatisticsReport() async {
    try {
      final dto = await remoteDataSource.getCallStatisticsReport();
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
