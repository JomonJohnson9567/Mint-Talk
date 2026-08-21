part of 'call_screen_cubit.dart';

enum CallScreenStatus {
  initial,
  initiating,
  ringing,
  connecting,
  active,
  ended,
  insufficientBalance,
  failed,
}

enum CallMediaStatus {
  idle,
  requestingPermissions,
  initializing,
  joining,
  waitingForRemote,
  active,
  reconnecting,
  failed,
  ended,
}

enum NetworkQualityLevel { unknown, good, poor, bad }

/// Network-derived signals for the active call, kept as one value object
/// since they change together and have their own transition rules distinct
/// from [CallMediaStatus] (which tracks the local Agora media path only).
class CallNetworkStatus extends Equatable {
  final bool isLocalDeviceOffline;
  final bool isRemoteReconnecting;
  final NetworkQualityLevel localQuality;
  final NetworkQualityLevel remoteQuality;

  const CallNetworkStatus({
    this.isLocalDeviceOffline = false,
    this.isRemoteReconnecting = false,
    this.localQuality = NetworkQualityLevel.unknown,
    this.remoteQuality = NetworkQualityLevel.unknown,
  });

  bool get hasNetworkIssue =>
      isLocalDeviceOffline ||
      isRemoteReconnecting ||
      localQuality == NetworkQualityLevel.bad ||
      remoteQuality == NetworkQualityLevel.bad;

  CallNetworkStatus copyWith({
    bool? isLocalDeviceOffline,
    bool? isRemoteReconnecting,
    NetworkQualityLevel? localQuality,
    NetworkQualityLevel? remoteQuality,
  }) {
    return CallNetworkStatus(
      isLocalDeviceOffline: isLocalDeviceOffline ?? this.isLocalDeviceOffline,
      isRemoteReconnecting: isRemoteReconnecting ?? this.isRemoteReconnecting,
      localQuality: localQuality ?? this.localQuality,
      remoteQuality: remoteQuality ?? this.remoteQuality,
    );
  }

  @override
  List<Object?> get props => [
    isLocalDeviceOffline,
    isRemoteReconnecting,
    localQuality,
    remoteQuality,
  ];
}

class CallScreenState extends Equatable {
  final CallScreenStatus status;
  final CallMediaStatus mediaStatus;
  final CallSessionEntity? session;
  final int durationSeconds;
  final bool isMuted;
  final bool isVideoMuted;
  final bool isSpeakerOn;
  final bool isRemoteUserJoined;
  final int? remoteUid;
  final String errorMessage;
  final int waveStep;
  final CallNetworkStatus networkStatus;
  final bool controlsVisible;

  const CallScreenState({
    this.status = CallScreenStatus.initial,
    this.mediaStatus = CallMediaStatus.idle,
    this.session,
    this.durationSeconds = 0,
    this.isMuted = false,
    this.isVideoMuted = false,
    this.isSpeakerOn = false,
    this.isRemoteUserJoined = false,
    this.remoteUid,
    this.errorMessage = '',
    this.waveStep = 0,
    this.networkStatus = const CallNetworkStatus(),
    this.controlsVisible = true,
  });

  bool get isCallActive => status == CallScreenStatus.active;
  bool get isCallEnded =>
      status == CallScreenStatus.ended ||
      status == CallScreenStatus.insufficientBalance ||
      status == CallScreenStatus.failed;

  CallScreenState copyWith({
    CallScreenStatus? status,
    CallMediaStatus? mediaStatus,
    CallSessionEntity? session,
    int? durationSeconds,
    bool? isMuted,
    bool? isVideoMuted,
    bool? isSpeakerOn,
    bool? isRemoteUserJoined,
    int? remoteUid,
    String? errorMessage,
    int? waveStep,
    CallNetworkStatus? networkStatus,
    bool? controlsVisible,
  }) {
    return CallScreenState(
      status: status ?? this.status,
      mediaStatus: mediaStatus ?? this.mediaStatus,
      session: session ?? this.session,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isMuted: isMuted ?? this.isMuted,
      isVideoMuted: isVideoMuted ?? this.isVideoMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isRemoteUserJoined: isRemoteUserJoined ?? this.isRemoteUserJoined,
      remoteUid: remoteUid ?? this.remoteUid,
      errorMessage: errorMessage ?? this.errorMessage,
      waveStep: waveStep ?? this.waveStep,
      networkStatus: networkStatus ?? this.networkStatus,
      controlsVisible: controlsVisible ?? this.controlsVisible,
    );
  }

  @override
  List<Object?> get props => [
    status,
    mediaStatus,
    session,
    durationSeconds,
    isMuted,
    isVideoMuted,
    isSpeakerOn,
    isRemoteUserJoined,
    remoteUid,
    errorMessage,
    waveStep,
    networkStatus,
    controlsVisible,
  ];
}
