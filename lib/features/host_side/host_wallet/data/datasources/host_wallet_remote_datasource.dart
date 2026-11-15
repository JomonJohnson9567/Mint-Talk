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
    HostWithdrawalRequestModel request, {
    required String idempotencyKey,
  });
}

@LazySingleton(as: HostWalletRemoteDataSource)
class HostWalletRemoteDataSourceImpl implements HostWalletRemoteDataSource {
  final ApiClient apiClient;

  HostWalletRemoteDataSourceImpl(this.apiClient);

  /// Shorter than the 60 s default so a stalled withdrawal fails fast enough
  /// to be retried (with the same key) while the host is still looking.
  static const _connectTimeout = Duration(seconds: 15);
  static const _requestTimeout = Duration(seconds: 30);

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
    HostWithdrawalRequestModel request, {
    required String idempotencyKey,
  }) async {
    appLogger.d('HostWalletRemoteDataSourceImpl: submitting withdrawal');
    final response = await apiClient.post(
      ApiEndpoints.hostWithdrawalsRequest,
      requiresAuth: true,
      body: request.toJson(),
      headers: {'Idempotency-Key': idempotencyKey},
      connectTimeout: _connectTimeout,
      sendTimeout: _requestTimeout,
      receiveTimeout: _requestTimeout,
    );
    final data = response['data'];
    final withdrawal = data is Map<String, dynamic>
        ? (data['withdrawal'] is Map<String, dynamic>
              ? data['withdrawal'] as Map<String, dynamic>
              : data)
        : const <String, dynamic>{};
    return HostWithdrawalEntryModel.fromJson(withdrawal);
  }
}
