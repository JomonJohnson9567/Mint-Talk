import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/features/user_side/profile_setup/data/models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<bool> createProfile(UserProfileModel profile);
  Future<bool> verifyReferralCode(String referralCode);
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<bool> createProfile(UserProfileModel profile) async {
    final response = await _apiClient.patch(
      ApiEndpoints.updateProfile,
      requiresAuth: true,
      body: profile.toJson(),
    );
    return response['success'] == true;
  }

  @override
  Future<bool> verifyReferralCode(String referralCode) async {
    final response = await _apiClient.get(
      ApiEndpoints.referralVerify,
      requiresAuth: true,
      queryParams: {'referralCode': referralCode},
    );
    // Be flexible with success response formats
    return response['success'] == true || response['status'] == 'success';
  }
}
