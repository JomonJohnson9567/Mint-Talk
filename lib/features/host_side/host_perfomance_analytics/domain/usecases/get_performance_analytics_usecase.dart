import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/host_earnings_ledger_entity.dart';
import '../repositories/performance_analytics_repository.dart';

@injectable
class GetPerformanceAnalyticsUseCase
    implements UseCase<HostEarningsLedgerEntity, NoParams> {
  final PerformanceAnalyticsRepository repository;

  GetPerformanceAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, HostEarningsLedgerEntity>> call(NoParams params) {
    return repository.getPerformanceAnalytics();
  }
}
