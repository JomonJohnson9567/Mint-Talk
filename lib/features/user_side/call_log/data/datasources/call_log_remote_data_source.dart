import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/api_client.dart';
import '../models/call_log_dto.dart';
import '../models/call_statistics_dto.dart';

abstract class CallLogRemoteDataSource {
  Future<List<CallLogDto>> getUserCallLogs({
    String? status,
    int page = 1,
    int limit = 20,
  });

  Future<List<CallLogDto>> getHostCallLogs({
    String? status,
    int page = 1,
    int limit = 20,
  });

  Future<CallStatisticsDto> getCallStatisticsReport();
}

@LazySingleton(as: CallLogRemoteDataSource)
class CallLogRemoteDataSourceImpl implements CallLogRemoteDataSource {
  final ApiClient apiClient;

  CallLogRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<CallLogDto>> getUserCallLogs({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await apiClient.get(
        ApiEndpoints.userCallLogs,
        requiresAuth: true,
        queryParams: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        final dataMap = response['data'] as Map<String, dynamic>;
        final List items = dataMap['items'] is List ? dataMap['items'] as List : [];
        return items
            .map((item) => CallLogDto.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Failed to fetch user call logs',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<CallLogDto>> getHostCallLogs({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await apiClient.get(
        ApiEndpoints.hostCallLogs,
        requiresAuth: true,
        queryParams: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        final dataMap = response['data'] as Map<String, dynamic>;
        final List items = dataMap['items'] is List ? dataMap['items'] as List : [];
        return items
            .map((item) => CallLogDto.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Failed to fetch host call logs',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CallStatisticsDto> getCallStatisticsReport() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.callReportSummary,
        requiresAuth: true,
      );

      if (response['success'] == true) {
        return CallStatisticsDto.fromJson(response);
      }
      throw ServerException(
        message: response['message'] ?? 'Failed to fetch call statistics',
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Failed to fetch call statistics',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
