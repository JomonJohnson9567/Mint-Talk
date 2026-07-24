import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/call_statistics_report_entity.dart';
import '../repositories/call_log_repository.dart';

@injectable
class GetCallStatisticsUseCase implements UseCase<CallStatisticsReportEntity, NoParams> {
  final CallLogRepository repository;

  GetCallStatisticsUseCase(this.repository);

  @override
  Future<Either<Failure, CallStatisticsReportEntity>> call(NoParams params) {
    return repository.getCallStatisticsReport();
  }
}
