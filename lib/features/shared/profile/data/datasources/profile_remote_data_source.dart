import 'package:cached_network_image/cached_network_image.dart';
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
        final dto = ProfileImageDto.fromJson(response);
        // The backend serves the avatar from a stable per-user URL, so a
        // re-upload keeps the same URL with new bytes. Evict it so every
        // CachedNetworkImage showing this user's avatar (e.g. the "Hosts
        // Online" grid) re-fetches the new image instead of the stale one.
        if (dto.avatarUrl.isNotEmpty) {
          await CachedNetworkImage.evictFromCache(dto.avatarUrl);
        }
        return dto;
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
