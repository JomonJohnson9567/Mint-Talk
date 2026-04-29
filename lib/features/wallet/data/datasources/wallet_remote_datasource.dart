import 'package:mint_talk/core/constants/api_endpoints.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/features/wallet/data/models/order_model.dart';
import 'package:mint_talk/features/wallet/data/models/wallet_model.dart';
import 'package:mint_talk/features/user_side/recharge_plans/data/models/recharge_plan_item.dart';
import 'package:injectable/injectable.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> initializeWallet();
  Future<WalletModel> getWalletBalance(String userId);
  Future<OrderModel> createOrder(String planId);
  Future<int> verifyPayment(Map<String, dynamic> body);
  Future<List<RechargePlanItem>> getPlans();
}


@LazySingleton(as: WalletRemoteDataSource)
class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient apiClient;

  WalletRemoteDataSourceImpl(this.apiClient);

  @override
  Future<WalletModel> initializeWallet() async {
    final response = await apiClient.post(ApiEndpoints.walletInitialize, requiresAuth: true);
    
    final isSuccess = response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(message: response['message'] as String? ?? 'Failed to initialize wallet');
    }

    final data = response['data'] ?? response['wallet'];
    if (data == null) throw const ServerException(message: 'Wallet data not found in response');
    
    return WalletModel.fromJson(data);
  }

  @override
  Future<WalletModel> getWalletBalance(String userId) async {
    final response = await apiClient.get(ApiEndpoints.walletBalance(userId), requiresAuth: true);
    
    final isSuccess = response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(message: response['message'] as String? ?? 'Failed to fetch wallet balance');
    }

    final data = response['data'] ?? response['wallet'];
    if (data == null) throw const ServerException(message: 'Wallet data not found in response');

    return WalletModel.fromJson(data);
  }

  @override
  Future<OrderModel> createOrder(String planId) async {
    final response = await apiClient.post(
      ApiEndpoints.createOrder,
      requiresAuth: true,
      body: {'planId': planId},
    );

    final isSuccess = response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(message: response['message'] as String? ?? 'Failed to create order');
    }

    // Ensure we capture all keys by merging nested data/order objects with the top-level response
    final Map<String, dynamic> mergedData = Map<String, dynamic>.from(response);
    if (response['data'] is Map<String, dynamic>) {
      mergedData.addAll(response['data'] as Map<String, dynamic>);
    }
    if (response['order'] is Map<String, dynamic>) {
      mergedData.addAll(response['order'] as Map<String, dynamic>);
    }
    
    return OrderModel.fromJson(mergedData);
  }

  @override
  Future<int> verifyPayment(Map<String, dynamic> body) async {
    final response = await apiClient.post(
      ApiEndpoints.verifyPayment,
      requiresAuth: true,
      body: body,
    );

    // ignore: avoid_print
    print('WalletRemoteDataSource.verifyPayment: Received response: $response');

    final isSuccess = response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(message: response['message'] as String? ?? 'Payment verification failed');
    }

    // Attempt to extract balance from various possible locations
    final walletData = response['wallet'] ?? response['data']?['wallet'] ?? response['data'];
    
    if (walletData != null && walletData is Map<String, dynamic>) {
      final balance = walletData['balance'];
      if (balance != null) return int.tryParse(balance.toString()) ?? 0;
    }
    
    // Fallback: look for balance at top level
    final topLevelBalance = response['balance'] ?? response['newBalance'];
    if (topLevelBalance != null) return int.tryParse(topLevelBalance.toString()) ?? 0;

    // ignore: avoid_print
    print('WalletRemoteDataSource.verifyPayment: WARNING - Could not find balance in response, defaulting to 0');
    return 0;
  }

  @override
  Future<List<RechargePlanItem>> getPlans() async {
    final response = await apiClient.get(ApiEndpoints.plans, requiresAuth: true);

    final isSuccess =
        response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(
          message: response['message'] as String? ?? 'Failed to fetch plans');
    }

    final List plansData = response['plans'] ?? response['data'] ?? [];
    // ignore: avoid_print
    print('WalletRemoteDataSource.getPlans: Received ${plansData.length} plans from API');
    
    return plansData.map((json) => RechargePlanItem.fromJson(json)).toList();
  }
}
