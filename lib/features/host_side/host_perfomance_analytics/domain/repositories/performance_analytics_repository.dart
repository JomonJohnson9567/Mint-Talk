import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/host_earnings_ledger_entity.dart';

abstract class PerformanceAnalyticsRepository {
  Future<Either<Failure, HostEarningsLedgerEntity>> getPerformanceAnalytics();
}
