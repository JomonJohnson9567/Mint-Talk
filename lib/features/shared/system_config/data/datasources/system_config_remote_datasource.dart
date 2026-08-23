import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/features/shared/system_config/data/models/system_config_model.dart';

abstract class SystemConfigRemoteDataSource {
  Future<SystemConfigModel> getSystemConfig();
}

@LazySingleton(as: SystemConfigRemoteDataSource)
class SystemConfigRemoteDataSourceImpl implements SystemConfigRemoteDataSource {
  final ApiClient apiClient;

  SystemConfigRemoteDataSourceImpl(this.apiClient);

  @override
  Future<SystemConfigModel> getSystemConfig() async {
    final response = await apiClient.get(ApiEndpoints.systemConfig);

    final isSuccess =
        response['success'] == true || response['status'] == 'success';
    if (!isSuccess && response['billingUnit'] == null) {
      throw ServerException(
        message:
            response['message'] as String? ?? 'Failed to fetch system config',
      );
    }

    final data = response['data'] ?? response;
    return SystemConfigModel.fromJson(data as Map<String, dynamic>);
  }
}
