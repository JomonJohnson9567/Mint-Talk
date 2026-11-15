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

/// Shown when the backend drops a call because the caller's points ran out.
const String insufficientBalanceEndedMessage =
    'Call ended: Your wallet balance ran out.';

/// Shown when an accepted call never became active (server `failed` /
/// `connection_timeout`). Nothing is charged in that case.
const String couldNotConnectMessage =
    'Could not connect. You were not charged.';

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

/// The device's audio situation during a call: where audio is routed, what
/// accessories are connected, and the ringer / Do Not Disturb mode (the
/// latter only known on Android).
class CallAudioStatus extends Equatable {
  /// The route the engine reports it's using — not just what was requested.
  final CallAudioRoute route;
  final AudioOutputDevices devices;
  final DeviceSoundMode soundMode;

  const CallAudioStatus({
    this.route = CallAudioRoute.earpiece,
    this.devices = AudioOutputDevices.none,
    this.soundMode = DeviceSoundMode.unknown,
  });

  bool get isSpeakerOn => route == CallAudioRoute.speaker;

  /// Routes the user can pick from. A wired headset replaces the earpiece
  /// (Android and iOS both drop the receiver while one is plugged in).
  List<CallAudioRoute> get availableRoutes => [
    if (devices.hasWiredHeadset)
      CallAudioRoute.wiredHeadset
    else
      CallAudioRoute.earpiece,
    CallAudioRoute.speaker,
    if (devices.hasBluetooth) CallAudioRoute.bluetooth,
  ];

  /// More than the plain speaker on/off pair — the UI shows a picker.
  bool get hasRouteChoice => availableRoutes.length > 2;

  CallAudioStatus copyWith({
    CallAudioRoute? route,
    AudioOutputDevices? devices,
    DeviceSoundMode? soundMode,
  }) {
    return CallAudioStatus(
      route: route ?? this.route,
      devices: devices ?? this.devices,
      soundMode: soundMode ?? this.soundMode,
    );
  }

  @override
  List<Object?> get props => [route, devices, soundMode];
}

class CallScreenState extends Equatable {
  final CallScreenStatus status;
  final CallMediaStatus mediaStatus;
  final CallSessionEntity? session;
  final int durationSeconds;
  final bool isMuted;
  final bool isVideoMuted;
  final CallAudioStatus audio;
  final bool isRemoteUserJoined;
  final int? remoteUid;
  final String errorMessage;
  final int waveStep;
  final CallNetworkStatus networkStatus;
  final bool controlsVisible;

  /// True while the call is minimized to the floating bubble (back was
  /// pressed mid-call) — the call itself (Agora session, timers, sockets)
  /// keeps running underneath regardless of this flag.
  final bool isMinimized;

  /// Display data for the other participant. Owned by state (not passed as
  /// widget constructor args) so a bubble-triggered restore, which re-pushes
  /// [CallScreen] with no arguments, can still render the right name/avatar.
  final String displayName;
  final String? avatarUrl;
  final bool isHost;

  /// True when the call failed because the caller's wallet can't cover it
  /// (HTTP 400 "Insufficient wallet balance" from POST /calls/initiate) —
  /// the UI routes this to the Recharge Wallet prompt instead of the
  /// generic failed-call snackbar.
  final bool requiresRecharge;

  /// True once this device's POST /activate returned `accepted` — our media
  /// is confirmed but the peer's isn't yet, so billing hasn't started.
  final bool isAwaitingPeerActivation;

  /// The host and call type this caller dialled. Set when the outgoing call
  /// starts, before [session] exists (it only arrives with the
  /// /calls/initiate response), so "Call again" and the audio/video layout
  /// choice don't depend on that request having succeeded.
  final String? hostId;
  final CallType? callType;

  /// Whether the dialled host is in the caller's favourites — seeds the
  /// post-call "Add Favorites" button.
  final bool isHostFavorite;

  /// The host this caller dialled, kept live with that host's socket
  /// presence (see CallScreenCubit._watchDialledHostPresence) so "Call
  /// again" can offer the same audio/video choice as the home screen.
  final HostEntity? dialledHost;

  const CallScreenState({
    this.status = CallScreenStatus.initial,
    this.mediaStatus = CallMediaStatus.idle,
    this.session,
    this.durationSeconds = 0,
    this.isMuted = false,
    this.isVideoMuted = false,
    this.audio = const CallAudioStatus(),
    this.isRemoteUserJoined = false,
    this.remoteUid,
    this.errorMessage = '',
    this.waveStep = 0,
    this.networkStatus = const CallNetworkStatus(),
    this.controlsVisible = true,
    this.isMinimized = false,
    this.displayName = '',
    this.avatarUrl,
    this.isHost = false,
    this.requiresRecharge = false,
    this.isAwaitingPeerActivation = false,
    this.hostId,
    this.callType,
    this.isHostFavorite = false,
    this.dialledHost,
  });

  bool get isCallActive => status == CallScreenStatus.active;

  /// A call is being placed, ringing, connecting or in progress — whether
  /// it's on the full call screen or minimised to the bubble / PiP.
  bool get isCallLive => switch (status) {
    CallScreenStatus.initiating ||
    CallScreenStatus.ringing ||
    CallScreenStatus.connecting ||
    CallScreenStatus.active => true,
    _ => false,
  };

  /// An active video call — leaving the app shrinks it into the floating
  /// picture-in-picture window (Android) instead of hiding it.
  bool get isPipEligible =>
      isCallActive && ((session?.callType ?? callType)?.isVideo ?? false);
  bool get isSpeakerOn => audio.isSpeakerOn;
  bool get isCallEnded =>
      status == CallScreenStatus.ended ||
      status == CallScreenStatus.insufficientBalance ||
      status == CallScreenStatus.failed;

  /// Caller's call rang out unanswered — either this device's own ring
  /// limit cancelled it or the server pushed `call_missed`.
  bool get isNoAnswer =>
      !isHost &&
      isCallEnded &&
      (session?.endReason == CallScreenCubit.noAnswerEndReason ||
          session?.status.toLowerCase() == 'missed');

  CallScreenState copyWith({
    CallScreenStatus? status,
    CallMediaStatus? mediaStatus,
    CallSessionEntity? session,
    int? durationSeconds,
    bool? isMuted,
    bool? isVideoMuted,
    CallAudioStatus? audio,
    bool? isRemoteUserJoined,
    int? remoteUid,
    String? errorMessage,
    int? waveStep,
    CallNetworkStatus? networkStatus,
    bool? controlsVisible,
    bool? isMinimized,
    String? displayName,
    String? avatarUrl,
    bool? isHost,
    bool? requiresRecharge,
    bool? isAwaitingPeerActivation,
    String? hostId,
    CallType? callType,
    bool? isHostFavorite,
    HostEntity? dialledHost,
  }) {
    return CallScreenState(
      status: status ?? this.status,
      mediaStatus: mediaStatus ?? this.mediaStatus,
      session: session ?? this.session,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isMuted: isMuted ?? this.isMuted,
      isVideoMuted: isVideoMuted ?? this.isVideoMuted,
      audio: audio ?? this.audio,
      isRemoteUserJoined: isRemoteUserJoined ?? this.isRemoteUserJoined,
      remoteUid: remoteUid ?? this.remoteUid,
      errorMessage: errorMessage ?? this.errorMessage,
      waveStep: waveStep ?? this.waveStep,
      networkStatus: networkStatus ?? this.networkStatus,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      isMinimized: isMinimized ?? this.isMinimized,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isHost: isHost ?? this.isHost,
      requiresRecharge: requiresRecharge ?? this.requiresRecharge,
      isAwaitingPeerActivation:
          isAwaitingPeerActivation ?? this.isAwaitingPeerActivation,
      hostId: hostId ?? this.hostId,
      callType: callType ?? this.callType,
      isHostFavorite: isHostFavorite ?? this.isHostFavorite,
      dialledHost: dialledHost ?? this.dialledHost,
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
    audio,
    isRemoteUserJoined,
    remoteUid,
    errorMessage,
    waveStep,
    networkStatus,
    controlsVisible,
    isMinimized,
    displayName,
    avatarUrl,
    isHost,
    requiresRecharge,
    isAwaitingPeerActivation,
    hostId,
    callType,
    isHostFavorite,
    dialledHost,
  ];
}
