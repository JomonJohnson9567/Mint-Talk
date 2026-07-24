import 'package:injectable/injectable.dart';

import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/features/user_side/user_referral_status/data/models/referral_status_model.dart';

abstract class ReferralStatusRemoteDataSource {
  Future<ReferralStatusModel?> getReferralStatus(String userId);
}

@LazySingleton(as: ReferralStatusRemoteDataSource)
class ReferralStatusRemoteDataSourceImpl
    implements ReferralStatusRemoteDataSource {
  final ApiClient apiClient;

  ReferralStatusRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ReferralStatusModel?> getReferralStatus(String userId) async {
    final response = await apiClient.get(
      ApiEndpoints.referralStatus(userId),
      requiresAuth: true,
    );

    final isSuccess =
        response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(
        message:
            response['message'] as String? ?? 'Failed to load referral status',
      );
    }

    final data = response['data'] ?? response['referralData'];
    if (data == null) {
      return null;
    }

    if (data is Map<String, dynamic>) {
      return ReferralStatusModel.fromJson(data);
    }

    if (data is Map) {
      return ReferralStatusModel.fromJson(Map<String, dynamic>.from(data));
    }

    return null;
  }
}
