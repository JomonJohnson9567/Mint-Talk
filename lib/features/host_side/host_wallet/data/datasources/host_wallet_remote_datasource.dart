import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/core/utils/app_logger.dart';

import '../models/host_wallet_models.dart';

abstract class HostWalletRemoteDataSource {
  Future<HostWalletOverviewModel> getWalletOverview({
    int page = 1,
    int limit = 20,
  });

  Future<HostWithdrawalEntryModel> requestWithdrawal(
    HostWithdrawalRequestModel request,
  );
}

@LazySingleton(as: HostWalletRemoteDataSource)
class HostWalletRemoteDataSourceImpl implements HostWalletRemoteDataSource {
  final ApiClient apiClient;

  HostWalletRemoteDataSourceImpl(this.apiClient);

  @override
  Future<HostWalletOverviewModel> getWalletOverview({
    int page = 1,
    int limit = 20,
  }) async {
    appLogger.d('HostWalletRemoteDataSourceImpl: loading withdrawal overview');
    final response = await apiClient.get(
      ApiEndpoints.hostWithdrawalsMyRequests,
      requiresAuth: true,
      queryParams: {'page': page, 'limit': limit},
    );
    return HostWalletOverviewModel.fromJson(response);
  }

  @override
  Future<HostWithdrawalEntryModel> requestWithdrawal(
    HostWithdrawalRequestModel request,
  ) async {
    appLogger.d('HostWalletRemoteDataSourceImpl: submitting withdrawal');
    final response = await apiClient.post(
      ApiEndpoints.hostWithdrawalsRequest,
      requiresAuth: true,
      body: request.toJson(),
    );
    final data = (response['data'] as Map<String, dynamic>? ?? const {});
    return HostWithdrawalEntryModel.fromJson(data);
  }
}
