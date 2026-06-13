import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import '../models/host_application_model.dart';

abstract class HostApplicationRemoteDataSource {
  Future<bool> submitApplication(HostApplicationModel model);
}

@LazySingleton(as: HostApplicationRemoteDataSource)
class HostApplicationRemoteDataSourceImpl implements HostApplicationRemoteDataSource {
  final ApiClient apiClient;

  HostApplicationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<bool> submitApplication(HostApplicationModel model) async {
    final requestBody = {
      'bio': model.bio,
    };

    appLogger.d('HostApplicationRemoteDataSource.submitApplication: Sending POST to ${ApiEndpoints.applyForHost}\nRequest Body: $requestBody');

    final response = await apiClient.post(
      ApiEndpoints.applyForHost,
      requiresAuth: true,
      body: requestBody,
    );

    appLogger.d('HostApplicationRemoteDataSource.submitApplication: Received response:\n$response');

    final isSuccess = response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(
        message: response['message'] as String? ?? 'Failed to submit host application',
      );
    }
    return true;
  }
}
