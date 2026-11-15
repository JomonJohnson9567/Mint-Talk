import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/host_earnings_ledger_entity.dart';
import '../repositories/performance_analytics_repository.dart';

@injectable
class GetPerformanceAnalyticsUseCase
    implements UseCase<HostEarningsLedgerEntity, EarningsLedgerScope> {
  final PerformanceAnalyticsRepository repository;

  GetPerformanceAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, HostEarningsLedgerEntity>> call(
    EarningsLedgerScope scope,
  ) {
    return repository.getPerformanceAnalytics(scope: scope);
  }
}
