import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import '../models/host_application_model.dart';

abstract class HostApplicationRemoteDataSource {
  Future<bool> submitApplication(HostApplicationModel model);
  Future<String> uploadImage(String imagePath, String key);
}

@LazySingleton(as: HostApplicationRemoteDataSource)
class HostApplicationRemoteDataSourceImpl implements HostApplicationRemoteDataSource {
  final ApiClient apiClient;

  HostApplicationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<bool> submitApplication(HostApplicationModel model) async {
    // 1. Send Host Application Bio
    final applyBody = {
      'bio': model.bio,
    };

    appLogger.d('HostApplicationRemoteDataSource.submitApplication: Sending POST to ${ApiEndpoints.applyForHost}\nBody: $applyBody');

    final applyResponse = await apiClient.post(
      ApiEndpoints.applyForHost,
      requiresAuth: true,
      body: applyBody,
    );

    appLogger.d('HostApplicationRemoteDataSource.submitApplication: Received apply response:\n$applyResponse');

    final isApplySuccess = applyResponse['success'] == true || applyResponse['status'] == 'success';
    if (!isApplySuccess) {
      throw ServerException(
        message: applyResponse['message'] as String? ?? 'Failed to submit host application bio',
      );
    }

    // 2. Format Aadhaar number to replace spaces with dashes (e.g., "1234-5678-9012")
    final formattedAadhaar = model.aadhaarNumber.replaceAll(' ', '-');

    // 3. Prepare KYC verification body as JSON using uploaded image URL strings
    final kycBody = <String, dynamic>{
      'documentType': 'aadhar',
      'documentNumber': formattedAadhaar,
      'frontPageUrl': model.aadhaarFront,
      'backPageUrl': model.aadhaarBack,
      'selfieUrl': model.selfie,
    };

    appLogger.d('HostApplicationRemoteDataSource.submitApplication: Sending KYC JSON POST to ${ApiEndpoints.verifyKYC}');

    final kycResponse = await apiClient.post(
      ApiEndpoints.verifyKYC,
      requiresAuth: true,
      body: kycBody,
    );

    appLogger.d('HostApplicationRemoteDataSource.submitApplication: Received KYC response:\n$kycResponse');

    final isKycSuccess = kycResponse['success'] == true || kycResponse['status'] == 'success';
    if (!isKycSuccess) {
      throw ServerException(
        message: kycResponse['message'] as String? ?? 'Failed to submit KYC verification documents',
      );
    }

    return true;
  }

  @override
  Future<String> uploadImage(String imagePath, String key) async {
    appLogger.d('HostApplicationRemoteDataSource.uploadImage: Mocking upload for key $key');
    if (key == 'frontPageUrl') {
      return 'https://example.com/kyc/aadhar-front.jpg';
    } else if (key == 'backPageUrl') {
      return 'https://example.com/kyc/aadhar-back.jpg';
    } else {
      return 'https://example.com/kyc/selfie.jpg';
    }
  }
}
