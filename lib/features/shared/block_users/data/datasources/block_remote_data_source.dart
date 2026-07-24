import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/api_client.dart';
import '../models/blocked_user_dto.dart';

abstract class BlockRemoteDataSource {
  Future<List<BlockedUserDto>> getBlockedList();
  Future<void> blockUser(String userId);
  Future<void> unblockUser(String userId);
}

@LazySingleton(as: BlockRemoteDataSource)
class BlockRemoteDataSourceImpl implements BlockRemoteDataSource {
  final ApiClient apiClient;

  BlockRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<BlockedUserDto>> getBlockedList() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.blockedList,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] is List) {
        final List list = response['data'] as List;
        return list
            .map((item) => BlockedUserDto.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Failed to fetch blocked users',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> blockUser(String userId) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.blockUser,
        requiresAuth: true,
        body: {'blockedId': userId},
      );

      if (response['success'] != true) {
        throw ServerException(
          message: response['message'] ?? 'Failed to block user',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Failed to block user',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unblockUser(String userId) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.unblockUser,
        requiresAuth: true,
        body: {'blockedId': userId},
      );

      if (response['success'] != true) {
        throw ServerException(
          message: response['message'] ?? 'Failed to unblock user',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Failed to unblock user',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
