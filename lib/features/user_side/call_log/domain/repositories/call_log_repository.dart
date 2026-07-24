import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/call_log_entity.dart';
import '../entities/call_statistics_report_entity.dart';

abstract class CallLogRepository {
  Future<Either<Failure, List<CallLogEntity>>> getUserCallLogs({
    String? status,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, List<CallLogEntity>>> getHostCallLogs({
    String? status,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, CallStatisticsReportEntity>> getCallStatisticsReport();
}
