import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/features/user_side/home/data/models/paginated_hosts_dto.dart';

abstract class FavoritesRemoteDataSource {
  Future<void> addFavorite(String hostId);
  Future<void> removeFavorite(String hostId);
  Future<PaginatedHostsDto> getFavoriteHosts({int? page, int? limit});
}

@LazySingleton(as: FavoritesRemoteDataSource)
class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final ApiClient apiClient;

  FavoritesRemoteDataSourceImpl(this.apiClient);

  @override
  Future<void> addFavorite(String hostId) async {
    final response = await apiClient.post(
      ApiEndpoints.userFavoriteHost(hostId),
      requiresAuth: true,
    );
    _ensureSuccess(response, fallbackMessage: 'Failed to add favorite');
  }

  @override
  Future<void> removeFavorite(String hostId) async {
    final response = await apiClient.delete(
      ApiEndpoints.userFavoriteHost(hostId),
      requiresAuth: true,
    );
    _ensureSuccess(response, fallbackMessage: 'Failed to remove favorite');
  }

  @override
  Future<PaginatedHostsDto> getFavoriteHosts({int? page, int? limit}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.get(
        ApiEndpoints.userFavorites,
        requiresAuth: true,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response['success'] == true || response['status'] == 'success') {
        return PaginatedHostsDto.fromJson(response);
      }
      throw ServerException(
        message: response['message'] ?? 'Failed to fetch favorite hosts',
      );
    } catch (e) {
      if (e is DioException || e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  void _ensureSuccess(Map<String, dynamic> response, {required String fallbackMessage}) {
    if (response['success'] == true || response['status'] == 'success') return;
    throw ServerException(message: response['message'] ?? fallbackMessage);
  }
}
