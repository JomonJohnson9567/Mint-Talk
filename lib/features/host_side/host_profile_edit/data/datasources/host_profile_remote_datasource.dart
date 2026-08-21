import 'package:injectable/injectable.dart';
import '../../../../../core/constants/api_endpoints_user.dart';
import '../../../../../core/errors/exceptions.dart';
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

  HostProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<HostProfileModel> getHostProfile() async {
    final response = await apiClient.get(
      ApiEndpoints.updateProfile,
      requiresAuth: true,
    );
    appLogger.d('HostProfileRemoteDataSourceImpl.getHostProfile response:\n$response');

    final data = response['data'] ?? response['profile'] ?? response;
    if (data is Map<String, dynamic>) {
      return HostProfileModel.fromJson(data);
    }
    if (data is Map) {
      return HostProfileModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw const ServerException(message: 'Host profile data not found in response');
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

    return response['success'] == true ||
        response['status'] == 'success' ||
        response.containsKey('data') ||
        response.isNotEmpty;
  }
}

