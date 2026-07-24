import 'package:injectable/injectable.dart';
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

  // In-memory local cache simulating the remote database.
  // Defaults to values currently displayed on the Host Profile Screen.
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
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    return _cachedProfile;
  }

  @override
  Future<bool> updateHostProfile(HostProfileModel profile) async {
    appLogger.d('HostProfileRemoteDataSourceImpl: Updating host profile to: ${profile.fullName}');
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    _cachedProfile = profile;
    return true;
  }
}
