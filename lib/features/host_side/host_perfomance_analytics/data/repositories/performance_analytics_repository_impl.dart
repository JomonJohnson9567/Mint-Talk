import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../domain/entities/host_earnings_ledger_entity.dart';
import '../../domain/repositories/performance_analytics_repository.dart';
import '../datasources/performance_analytics_remote_datasource.dart';

@LazySingleton(as: PerformanceAnalyticsRepository)
class PerformanceAnalyticsRepositoryImpl implements PerformanceAnalyticsRepository {
  final PerformanceAnalyticsRemoteDataSource remoteDataSource;

  PerformanceAnalyticsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, HostEarningsLedgerEntity>> getPerformanceAnalytics() async {
    try {
      final model = await remoteDataSource.getPerformanceAnalytics();
      return Right(model);
    } catch (e, stackTrace) {
      appLogger.e(
        'PerformanceAnalyticsRepositoryImpl: Error getting performance analytics: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
