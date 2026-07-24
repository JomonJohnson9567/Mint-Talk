import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/call_report_entity.dart';
import '../../domain/repositories/call_report_repository.dart';
import '../datasources/call_report_remote_data_source.dart';

@LazySingleton(as: CallReportRepository)
class CallReportRepositoryImpl implements CallReportRepository {
  final CallReportRemoteDataSource remoteDataSource;

  CallReportRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, CallReportEntity>> reportCallMisconduct({
    required String callId,
    required String reason,
    required String description,
  }) async {
    try {
      final dto = await remoteDataSource.reportCall(
        callId: callId,
        reason: reason,
        description: description,
      );
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
