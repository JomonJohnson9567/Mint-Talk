import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/core/utils/app_logger.dart';

import '../models/host_earnings_ledger_model.dart';

abstract class PerformanceAnalyticsRemoteDataSource {
  Future<HostEarningsLedgerModel> getPerformanceAnalytics({
    int page = 1,
    int limit = 20,
  });
}

@LazySingleton(as: PerformanceAnalyticsRemoteDataSource)
class PerformanceAnalyticsRemoteDataSourceImpl
    implements PerformanceAnalyticsRemoteDataSource {
  final ApiClient apiClient;

  PerformanceAnalyticsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<HostEarningsLedgerModel> getPerformanceAnalytics({
    int page = 1,
    int limit = 20,
  }) async {
    appLogger.d(
      'PerformanceAnalyticsRemoteDataSourceImpl: Fetching earnings ledger',
    );

    final response = await apiClient.get(
      ApiEndpoints.hostMyEarningsLedger,
      requiresAuth: true,
      queryParams: {
        'page': page,
        'limit': limit,
      },
    );

    return HostEarningsLedgerModel.fromJson(response);
  }
}
