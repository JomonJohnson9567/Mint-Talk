import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/api_client.dart';
import '../models/call_report_dto.dart';

abstract class CallReportRemoteDataSource {
  Future<CallReportDto> reportCall({
    required String callId,
    required String reason,
    required String description,
  });
}

@LazySingleton(as: CallReportRemoteDataSource)
class CallReportRemoteDataSourceImpl implements CallReportRemoteDataSource {
  final ApiClient apiClient;

  CallReportRemoteDataSourceImpl(this.apiClient);

  @override
  Future<CallReportDto> reportCall({
    required String callId,
    required String reason,
    required String description,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.reportCall(callId),
        requiresAuth: true,
        body: {
          'reason': reason,
          'description': description,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return CallReportDto.fromJson(response['data'] as Map<String, dynamic>);
      }
      throw ServerException(
        message: response['message'] ?? 'Failed to report call',
      );
    } catch (e) {
      if (e is DioException || e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
