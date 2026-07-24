import 'package:equatable/equatable.dart';
import '../../domain/entities/host_dashboard_data_entity.dart';
import '../../domain/entities/host_online_item_entity.dart';
import '../../domain/entities/host_preferences_entity.dart';

enum HostDashStatus { initial, loading, success, failure }

enum HostPreferenceUpdateStatus { initial, loading, success, failure }

enum HostDashCallFlowMode { selecting, incomingCall, waitingForNextCall }

class HostDashState extends Equatable {
  final HostDashStatus status;
  final HostPreferenceUpdateStatus preferenceUpdateStatus;
  final HostDashCallFlowMode callFlowMode;
  final bool isVideoSelected;
  final bool isAudioSelected;
  final bool isStartingCall;
  final HostDashboardDataEntity? dashboardData;
  final HostPreferencesEntity? preferences;
  final String? errorMessage;
  final List<HostOnlineItemEntity> onlineHosts;
  final bool isHostsLoading;

  const HostDashState({
    this.status = HostDashStatus.initial,
    this.preferenceUpdateStatus = HostPreferenceUpdateStatus.initial,
    this.callFlowMode = HostDashCallFlowMode.selecting,
    this.isVideoSelected = true, // Default matches mockup
    this.isAudioSelected = false, // Default matches mockup
    this.isStartingCall = false,
    this.dashboardData,
    this.preferences,
    this.errorMessage,
    this.onlineHosts = const [],
    this.isHostsLoading = false,
  });

  HostDashState copyWith({
    HostDashStatus? status,
    HostPreferenceUpdateStatus? preferenceUpdateStatus,
    HostDashCallFlowMode? callFlowMode,
    bool? isVideoSelected,
    bool? isAudioSelected,
    bool? isStartingCall,
    HostDashboardDataEntity? dashboardData,
    HostPreferencesEntity? preferences,
    String? errorMessage,
    List<HostOnlineItemEntity>? onlineHosts,
    bool? isHostsLoading,
  }) {
    return HostDashState(
      status: status ?? this.status,
      preferenceUpdateStatus:
          preferenceUpdateStatus ?? this.preferenceUpdateStatus,
      callFlowMode: callFlowMode ?? this.callFlowMode,
      isVideoSelected: isVideoSelected ?? this.isVideoSelected,
      isAudioSelected: isAudioSelected ?? this.isAudioSelected,
      isStartingCall: isStartingCall ?? this.isStartingCall,
      dashboardData: dashboardData ?? this.dashboardData,
      preferences: preferences ?? this.preferences,
      errorMessage: errorMessage ?? this.errorMessage,
      onlineHosts: onlineHosts ?? this.onlineHosts,
      isHostsLoading: isHostsLoading ?? this.isHostsLoading,
    );
  }

  bool get isAnyCallSelected => isVideoSelected || isAudioSelected;

  String get selectedCallLabel {
    if (isAudioSelected && isVideoSelected) {
      return 'Audio + Video Call';
    }
    if (isAudioSelected) {
      return 'Audio Call';
    }
    return 'Video Call';
  }

  @override
  List<Object?> get props => [
    status,
    preferenceUpdateStatus,
    callFlowMode,
    isVideoSelected,
    isAudioSelected,
    isStartingCall,
    dashboardData,
    preferences,
    errorMessage,
    onlineHosts,
    isHostsLoading,
  ];
}

