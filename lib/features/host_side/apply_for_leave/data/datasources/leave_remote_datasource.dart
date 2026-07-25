import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/data/models/leave_request_model.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/data/models/leave_history_model.dart';

abstract class LeaveRemoteDataSource {
  Future<void> applyForLeave(LeaveRequestModel model);
  Future<int> getAvailableDays();
  Future<LeaveHistoryPageModel> getLeaveHistory({
    int page = 1,
    int limit = 20,
  });
}

@LazySingleton(as: LeaveRemoteDataSource)
class LeaveRemoteDataSourceImpl implements LeaveRemoteDataSource {
  final ApiClient apiClient;

  LeaveRemoteDataSourceImpl(this.apiClient);

  @override
  Future<void> applyForLeave(LeaveRequestModel model) async {
    try {
      appLogger.d('LeaveRemoteDataSource: Applying for leave with: ${model.toJson()}');
      final response = await apiClient.post(
        ApiEndpoints.hostLeavesRequest,
        body: model.toJson(),
      );

      if (response['status'] == 'error' || response['success'] == false) {
        throw ServerException(
          message: response['message'] ?? 'Failed to submit leave request',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Failed to submit leave request',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<int> getAvailableDays() async {
    appLogger.d('LeaveRemoteDataSource: Fetching available leave days');
    return 12;
  }

  @override
  Future<LeaveHistoryPageModel> getLeaveHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      appLogger.d('LeaveRemoteDataSource: Fetching leave history');
      final response = await apiClient.get(
        ApiEndpoints.hostLeavesMyRequests,
        queryParams: {'page': page, 'limit': limit},
      );
      return LeaveHistoryPageModel.fromJson(response);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Failed to fetch leave history',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
