import 'package:flutter/foundation.dart';
import 'package:mint_talk/config/env/env_config.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/features/user_side/wallet/data/models/order_model.dart';
import 'package:mint_talk/features/user_side/wallet/data/models/recharge_plan_model.dart';
import 'package:mint_talk/features/user_side/wallet/data/models/wallet_model.dart';
import 'package:injectable/injectable.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> initializeWallet();
  Future<WalletModel> getWalletBalance(String userId);
  Future<OrderModel> createOrder(String planId);
  Future<int> verifyPayment(Map<String, dynamic> body);
  Future<List<RechargePlanModel>> getPlans();
  Future<RechargePlanModel> getPlanById(String planId);
}

@LazySingleton(as: WalletRemoteDataSource)
class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient apiClient;
  final EnvConfig envConfig;

  WalletRemoteDataSourceImpl(this.apiClient, this.envConfig);

  @override
  Future<WalletModel> initializeWallet() async {
    final response = await apiClient.post(
      ApiEndpoints.walletInitialize,
      requiresAuth: true,
    );

    final isSuccess =
        response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(
        message:
            response['message'] as String? ?? 'Failed to initialize wallet',
      );
    }

    final data = response['data'] ?? response['wallet'];
    if (data == null) {
      throw const ServerException(message: 'Wallet data not found in response');
    }

    return WalletModel.fromJson(data);
  }

  @override
  Future<WalletModel> getWalletBalance(String userId) async {
    final response = await apiClient.get(
      ApiEndpoints.walletBalance(userId),
      requiresAuth: true,
    );

    final isSuccess =
        response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(
        message:
            response['message'] as String? ?? 'Failed to fetch wallet balance',
      );
    }

    final data = response['data'] ?? response['wallet'];
    if (data == null) {
      throw const ServerException(message: 'Wallet data not found in response');
    }

    return WalletModel.fromJson(data);
  }

  @override
  Future<OrderModel> createOrder(String planId) async {
    final response = await apiClient.post(
      ApiEndpoints.createOrder,
      requiresAuth: true,
      body: {'planId': planId},
    );

    final isSuccess =
        response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(
        message: response['message'] as String? ?? 'Failed to create order',
      );
    }

    // Ensure we capture all keys by merging nested data/order objects with the top-level response
    final Map<String, dynamic> mergedData = Map<String, dynamic>.from(response);
    if (response['data'] is Map<String, dynamic>) {
      mergedData.addAll(response['data'] as Map<String, dynamic>);
    }
    if (response['order'] is Map<String, dynamic>) {
      mergedData.addAll(response['order'] as Map<String, dynamic>);
    }

    return OrderModel.fromJson(mergedData, fallbackRazorpayKey: envConfig.razorpayKey);
  }

  @override
  Future<int> verifyPayment(Map<String, dynamic> body) async {
    final response = await apiClient.post(
      ApiEndpoints.verifyPayment,
      requiresAuth: true,
      body: body,
    );

    if (kDebugMode) {
      appLogger.d(
        'WalletRemoteDataSource.verifyPayment: Received response: $response',
      );
    }

    final isSuccess =
        response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(
        message:
            response['message'] as String? ?? 'Payment verification failed',
      );
    }

    // Attempt to extract balance from various possible locations
    final walletData =
        response['wallet'] ?? response['data']?['wallet'] ?? response['data'];

    if (walletData != null && walletData is Map<String, dynamic>) {
      final balance = walletData['balance'];
      if (balance != null) {
        return int.tryParse(balance.toString()) ?? 0;
      }
    }

    // Fallback: look for balance at top level
    final topLevelBalance = response['balance'] ?? response['newBalance'];
    if (topLevelBalance != null) {
      return int.tryParse(topLevelBalance.toString()) ?? 0;
    }

    appLogger.w(
      'WalletRemoteDataSource.verifyPayment: WARNING - Could not find balance in response, defaulting to 0',
    );
    return 0;
  }

  @override
  Future<List<RechargePlanModel>> getPlans() async {
    final response = await apiClient.get(
      ApiEndpoints.plans,
      requiresAuth: true,
    );

    final isSuccess =
        response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(
        message: response['message'] as String? ?? 'Failed to fetch plans',
      );
    }

    final List plansData = response['plans'] ?? response['data'] ?? [];
    appLogger.d(
      'WalletRemoteDataSource.getPlans: Received ${plansData.length} plans from API',
    );

    return plansData.map((json) => RechargePlanModel.fromJson(json)).toList();
  }

  @override
  Future<RechargePlanModel> getPlanById(String planId) async {
    final response = await apiClient.get(
      ApiEndpoints.planById(planId),
      requiresAuth: true,
    );

    final isSuccess =
        response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(
        message: response['message'] as String? ?? 'Failed to fetch plan',
      );
    }

    final data =
        response['data'] ??
        response['plan'] ??
        response['rechargePlan'] ??
        response;

    if (data is Map<String, dynamic>) {
      return RechargePlanModel.fromJson(data);
    }
    if (data is Map) {
      return RechargePlanModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw const ServerException(message: 'Plan data not found in response');
  }
}
