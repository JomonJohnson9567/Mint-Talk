import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'call_audio_route.dart';

abstract class IAgoraService {
  /// Stream of unified Agora call events.
  Stream<AgoraCallEvent> get events;

  /// Underlying Agora RTC Engine reference (if initialized).
  RtcEngine? get engine;

  /// Initializes the Agora RTC Engine with the target [appId].
  Future<void> initialize(String appId);

  /// Joins the Agora channel with the numeric [uid] the RTC token was
  /// issued for — caller 1, host 2, scoped to this call's channel.
  Future<void> joinChannel({
    required String channelName,
    required String rtcToken,
    required int uid,
    required bool isVideoCall,
  });

  /// Leaves the active Agora channel.
  Future<void> leaveChannel();

  /// Renews the Agora RTC token.
  Future<void> renewToken(String token);

  /// Toggles microphone mute.
  Future<void> toggleMuteAudio(bool isMuted);

  /// Toggles video stream state.
  Future<void> toggleMuteVideo(bool isMuted);

  /// Routes call audio to [route]. The route actually applied is reported
  /// back through [AgoraAudioRouteChanged] — treat that as the truth.
  Future<void> setAudioRoute(CallAudioRoute route);

  /// Cleans up resources and disposes the RTC Engine.
  Future<void> dispose();
}

sealed class AgoraCallEvent {
  const AgoraCallEvent();
}

class AgoraLocalJoinSuccess extends AgoraCallEvent {
  const AgoraLocalJoinSuccess();
}

class AgoraRemoteUserJoined extends AgoraCallEvent {
  const AgoraRemoteUserJoined(this.remoteUid);

  final int remoteUid;
}

/// The first local audio frame was published to the channel — proof the
/// local microphone track is actually reaching Agora, not just that the
/// join succeeded.
class AgoraLocalAudioPublished extends AgoraCallEvent {
  const AgoraLocalAudioPublished();
}

/// Audio from [remoteUid] is being received. Also emitted when the remote
/// joined with their mic muted — their track is published, just silent.
class AgoraRemoteAudioReceived extends AgoraCallEvent {
  const AgoraRemoteAudioReceived(this.remoteUid);

  final int remoteUid;
}

/// Local capture/publish failed (microphone, or camera on a video call).
class AgoraLocalMediaFailed extends AgoraCallEvent {
  const AgoraLocalMediaFailed(this.reason);

  final String reason;
}

class AgoraRemoteUserLeft extends AgoraCallEvent {
  const AgoraRemoteUserLeft(this.remoteUid, this.reason);

  final int remoteUid;
  final UserOfflineReasonType reason;
}

/// Fires roughly every 2s per uid while in a channel. [remoteUid] is `0`
/// for the local user's own uplink/downlink quality (Agora's convention).
class AgoraNetworkQualityChanged extends AgoraCallEvent {
  const AgoraNetworkQualityChanged({
    required this.remoteUid,
    required this.txQuality,
    required this.rxQuality,
  });

  final int remoteUid;
  final QualityType txQuality;
  final QualityType rxQuality;
}

class AgoraConnectionChanged extends AgoraCallEvent {
  const AgoraConnectionChanged({
    required this.state,
    required this.reason,
  });

  final ConnectionStateType state;
  final ConnectionChangedReasonType reason;
}

class AgoraTokenWillExpire extends AgoraCallEvent {
  const AgoraTokenWillExpire();
}

class AgoraTokenExpired extends AgoraCallEvent {
  const AgoraTokenExpired();
}

/// The engine moved call audio to [route] — after [IAgoraService.setAudioRoute],
/// or on its own when a headset/Bluetooth device connects or disconnects.
class AgoraAudioRouteChanged extends AgoraCallEvent {
  const AgoraAudioRouteChanged(this.route);

  final CallAudioRoute route;
}

class AgoraCallError extends AgoraCallEvent {
  const AgoraCallError({
    required this.code,
    required this.message,
  });

  final ErrorCodeType code;
  final String message;
}

sealed class AgoraCallException implements Exception {
  const AgoraCallException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AgoraInitializationException extends AgoraCallException {
  const AgoraInitializationException(super.message);
}

class AgoraJoinException extends AgoraCallException {
  const AgoraJoinException(super.message);
}

class AgoraTokenException extends AgoraCallException {
  const AgoraTokenException(super.message);
}

class AgoraPermissionException extends AgoraCallException {
  const AgoraPermissionException(super.message);
}
