import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/features/user_side/profile_setup/data/models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<bool> createProfile(UserProfileModel profile);
  Future<bool> updateProfile(UserProfileModel profile);
  Future<bool> verifyReferralCode(String referralCode);
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<bool> createProfile(UserProfileModel profile) async {
    final payload = profile.toJson();
    final response = await _apiClient.patch(
      ApiEndpoints.updateProfile,
      requiresAuth: true,
      body: payload,
    );
    appLogger.d('ProfileRemoteDataSource.createProfile response:\n$response');
    return _isSuccessful(response);
  }

  @override
  Future<bool> updateProfile(UserProfileModel profile) async {
    final payload = profile.toUpdateJson();
    appLogger.d('ProfileRemoteDataSource.updateProfile payload:\n$payload');
    final response = await _apiClient.patch(
      ApiEndpoints.updateProfile,
      requiresAuth: true,
      body: payload,
    );
    appLogger.d('ProfileRemoteDataSource.updateProfile response:\n$response');
    return _isSuccessful(response);
  }

  bool _isSuccessful(Map<String, dynamic> response) =>
      response['success'] == true || response['status'] == 'success';

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
