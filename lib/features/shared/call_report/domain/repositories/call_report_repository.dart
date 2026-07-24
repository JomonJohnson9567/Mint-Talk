import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/call_report_entity.dart';

abstract class CallReportRepository {
  Future<Either<Failure, CallReportEntity>> reportCallMisconduct({
    required String callId,
    required String reason,
    required String description,
  });
}
