import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/call_report_entity.dart';
import '../repositories/call_report_repository.dart';

class ReportCallParams extends Equatable {
  final String callId;
  final String reason;
  final String description;

  const ReportCallParams({
    required this.callId,
    required this.reason,
    required this.description,
  });

  @override
  List<Object?> get props => [callId, reason, description];
}

@injectable
class ReportCallMisconductUseCase implements UseCase<CallReportEntity, ReportCallParams> {
  final CallReportRepository repository;

  ReportCallMisconductUseCase(this.repository);

  @override
  Future<Either<Failure, CallReportEntity>> call(ReportCallParams params) {
    return repository.reportCallMisconduct(
      callId: params.callId,
      reason: params.reason,
      description: params.description,
    );
  }
}
