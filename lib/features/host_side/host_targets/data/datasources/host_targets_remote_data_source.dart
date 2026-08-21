import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/api_client.dart';
import '../models/host_target_dto.dart';

abstract class HostTargetsRemoteDataSource {
  Future<List<HostTargetDto>> getMyTargets();
}

@LazySingleton(as: HostTargetsRemoteDataSource)
class HostTargetsRemoteDataSourceImpl implements HostTargetsRemoteDataSource {
  final ApiClient apiClient;

  HostTargetsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<HostTargetDto>> getMyTargets() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.hostMyTargets,
        requiresAuth: true,
      );

      if (response['success'] == true || response['status'] == 'success') {
        final data = response['data'];
        final rawList = data is List ? data : const [];
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(HostTargetDto.fromJson)
            .toList();
      }
      throw ServerException(
        message: response['message'] ?? 'Failed to fetch host targets',
      );
    } catch (e) {
      if (e is DioException || e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
