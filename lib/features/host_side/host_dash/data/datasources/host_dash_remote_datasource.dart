import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import '../models/host_dashboard_data_model.dart';
import '../models/host_preferences_model.dart';

abstract class HostDashRemoteDataSource {
  Future<HostDashboardDataModel> getDashboardData();
  Future<HostPreferencesModel> updatePreferences(HostPreferencesModel model);
}

@LazySingleton(as: HostDashRemoteDataSource)
class HostDashRemoteDataSourceImpl implements HostDashRemoteDataSource {
  final ApiClient apiClient;

  HostDashRemoteDataSourceImpl(this.apiClient);

  @override
  Future<HostDashboardDataModel> getDashboardData() async {
    appLogger.d('HostDashRemoteDataSource: Fetching host dashboard data');

    // Simulate API network latency
    await Future.delayed(const Duration(milliseconds: 600));

    // Mock response exactly matching the mockup data:
    // Hi! Shantha
    // Daily min covered Video: 135.25 min
    // Daily min covered Audio: 210.25 min
    // Total min covered Video: 980.5 min
    // Total min covered Audio: 1200.5 min
    // Video Targets: target, *7rs, *8rs.
    // Audio Targets: target, *3rs, *3.5rs.
    final mockJson = {
      'host_name': 'Shantha',
      'avatar_asset': 'assets/images/profile setup/female.jpg',
      'daily_min_covered_video': 135.25,
      'daily_min_covered_audio': 210.25,
      'total_min_covered_video': 980.5,
      'total_min_covered_audio': 1200.5,
      'video_target_hours': 7.0,
      'video_target_max_hours': 8.0,
      'audio_target_hours': 3.0,
      'audio_target_max_hours': 3.5,
    };

    return HostDashboardDataModel.fromJson(mockJson);
  }

  @override
  Future<HostPreferencesModel> updatePreferences(
    HostPreferencesModel model,
  ) async {
    appLogger.d(
      'HostDashRemoteDataSource: Updating preferences with: ${model.toJson()}',
    );

    final response = await apiClient.patch(
      ApiEndpoints.hostPreferences,
      body: model.toJson(),
      requiresAuth: true,
    );
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return HostPreferencesModel.fromJson(data);
    }

    return HostPreferencesModel.fromJson(response);
  }
}
