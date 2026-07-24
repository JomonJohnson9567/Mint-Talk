import 'package:injectable/injectable.dart';

import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/data/models/recharge_history_item_model.dart';

abstract class RechargeHistoryRemoteDataSource {
  Future<List<RechargeHistoryItemModel>> getRechargeHistory(String userId);
}

@LazySingleton(as: RechargeHistoryRemoteDataSource)
class RechargeHistoryRemoteDataSourceImpl
    implements RechargeHistoryRemoteDataSource {
  final ApiClient apiClient;

  RechargeHistoryRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<RechargeHistoryItemModel>> getRechargeHistory(String userId) async {
    final response = await apiClient.get(
      ApiEndpoints.rechargeHistory(userId),
      requiresAuth: true,
    );

    final isSuccess =
        response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(
        message: response['message'] as String? ?? 'Failed to load recharge history',
      );
    }

    final List<dynamic> rawItems = (response['data'] as List<dynamic>?) ?? const [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(RechargeHistoryItemModel.fromJson)
        .toList();

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }
}
