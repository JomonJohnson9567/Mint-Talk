import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/api_client.dart';
import '../models/paginated_hosts_dto.dart';

abstract class HostRemoteDataSource {
  Future<PaginatedHostsDto> getOnlineHosts({int? page, int? limit});
  Future<PaginatedHostsDto> getOnCallHosts({int? page, int? limit});
}

@LazySingleton(as: HostRemoteDataSource)
class HostRemoteDataSourceImpl implements HostRemoteDataSource {
  final ApiClient apiClient;

  HostRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaginatedHostsDto> getOnlineHosts({
    int? page,
    int? limit,
  }) async {
    return _fetchHosts(
      endpoint: ApiEndpoints.hostsOnline,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<PaginatedHostsDto> getOnCallHosts({
    int? page,
    int? limit,
  }) async {
    return _fetchHosts(
      endpoint: ApiEndpoints.hostsOnCall,
      page: page,
      limit: limit,
    );
  }

  Future<PaginatedHostsDto> _fetchHosts({
    required String endpoint,
    int? page,
    int? limit,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.get(
        endpoint,
        requiresAuth: true,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response['success'] == true || response['status'] == 'success') {
        return PaginatedHostsDto.fromJson(response);
      }
      throw ServerException(
        message: response['message'] ?? 'Failed to fetch host list',
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Failed to fetch host list',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
