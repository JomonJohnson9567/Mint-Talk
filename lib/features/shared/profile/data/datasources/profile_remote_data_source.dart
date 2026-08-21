import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/api_client.dart';
import '../models/profile_image_dto.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileImageDto> uploadProfileImage(String imagePath);
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ProfileImageDto> uploadProfileImage(String imagePath) async {
    try {
      final file = await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      );

      final response = await apiClient.postMultipart(
        ApiEndpoints.profileImage,
        requiresAuth: true,
        body: {
          'image': file,
        },
      );

      if (response['success'] == true || response['data'] != null) {
        return ProfileImageDto.fromJson(response);
      }
      throw ServerException(
        message: response['message'] ?? 'Failed to upload profile image',
      );
    } catch (e) {
      if (e is DioException || e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
