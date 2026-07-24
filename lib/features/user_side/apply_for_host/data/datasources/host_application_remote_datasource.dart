import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import '../models/host_application_model.dart';
import '../models/host_application_status_model.dart';

abstract class HostApplicationRemoteDataSource {
  Future<bool> submitApplication(HostApplicationModel model);
  Future<String> uploadImage(String imagePath, String key);
  Future<HostApplicationStatusModel> getApplicationStatus();
}

@LazySingleton(as: HostApplicationRemoteDataSource)
class HostApplicationRemoteDataSourceImpl
    implements HostApplicationRemoteDataSource {
  final ApiClient apiClient;

  HostApplicationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<bool> submitApplication(HostApplicationModel model) async {
    final body = model.toJson();

    appLogger.d(
      'HostApplicationRemoteDataSource.submitApplication: Sending POST to ${ApiEndpoints.applyForHost}\nBody: $body',
    );

    final response = await apiClient.post(
      ApiEndpoints.applyForHost,
      requiresAuth: true,
      body: body,
    );

    appLogger.d(
      'HostApplicationRemoteDataSource.submitApplication: Received response:\n$response',
    );

    final isSuccess =
        response['success'] == true || response['status'] == 'success';
    if (!isSuccess) {
      throw ServerException(
        message:
            response['message'] as String? ??
            'Failed to submit host application',
      );
    }

    return true;
  }

  @override
  Future<String> uploadImage(String imagePath, String key) async {
    appLogger.d(
      'HostApplicationRemoteDataSource.uploadImage: Mocking upload for key $key',
    );
    if (key == 'frontPageUrl') {
      return 'https://example.com/kyc/aadhar-front.jpg';
    } else if (key == 'backPageUrl') {
      return 'https://example.com/kyc/aadhar-back.jpg';
    } else {
      return 'https://example.com/kyc/selfie.jpg';
    }
  }

  @override
  Future<HostApplicationStatusModel> getApplicationStatus() async {
    final response = await apiClient.get(
      ApiEndpoints.hostApplicationStatus,
      requiresAuth: true,
    );
    if (response['success'] != true || response['data'] is! Map) {
      throw ServerException(
        message:
            response['message']?.toString() ??
            'Unable to load your host application status',
      );
    }
    return HostApplicationStatusModel.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }
}
