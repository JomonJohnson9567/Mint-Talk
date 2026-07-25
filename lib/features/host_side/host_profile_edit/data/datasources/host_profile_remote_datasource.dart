import 'package:injectable/injectable.dart';
import '../../../../../core/constants/api_endpoints_user.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/app_logger.dart';
import '../models/host_profile_model.dart';

abstract class HostProfileRemoteDataSource {
  Future<HostProfileModel> getHostProfile();
  Future<bool> updateHostProfile(HostProfileModel profile);
}

@LazySingleton(as: HostProfileRemoteDataSource)
class HostProfileRemoteDataSourceImpl implements HostProfileRemoteDataSource {
  final ApiClient apiClient;

  // Fallback local cache when offline or initial seed
  static HostProfileModel _cachedProfile = const HostProfileModel(
    id: 'Rm237349',
    fullName: 'Ramani Nair',
    email: 'ramani@gmail.com',
    phone: '9874563212',
    idNumber: 'Rm237349',
    dob: '12/08/1996',
    selectedCategories: ['Understanding', 'Empathy'],
    avatarAsset: 'assets/images/profile setup/female.jpg',
  );

  HostProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<HostProfileModel> getHostProfile() async {
    appLogger.d('HostProfileRemoteDataSourceImpl: Fetching host profile');
    return _cachedProfile;
  }

  @override
  Future<bool> updateHostProfile(HostProfileModel profile) async {
    final payload = profile.toUpdateJson();
    appLogger.d('HostProfileRemoteDataSourceImpl.updateHostProfile payload:\n$payload');
    
    final response = await apiClient.patch(
      ApiEndpoints.updateProfile,
      requiresAuth: true,
      body: payload,
    );
    appLogger.d('HostProfileRemoteDataSourceImpl.updateHostProfile response:\n$response');
    
    _cachedProfile = profile;
    return response['success'] == true ||
        response['status'] == 'success' ||
        response.containsKey('data') ||
        response.isNotEmpty;
  }
}

