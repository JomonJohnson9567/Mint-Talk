import 'package:agora_rtc_engine/agora_rtc_engine.dart';

abstract class IAgoraService {
  /// Stream that emits true when the remote participant successfully joins the channel.
  Stream<bool> get isRemoteUserJoined;

  /// Stream that emits the remote user's numeric UID when joined (or null when left).
  Stream<int?> get remoteUidStream;

  /// Underlying Agora RTC Engine reference (if initialized).
  RtcEngine? get engine;

  /// Initializes the Agora RTC Engine with the target [appId].
  Future<void> initialize(String appId);

  /// Joins the Agora channel with channel name, token, and user account string.
  ///
  /// As specified in the API contract:
  /// Both caller and host join using their [userId] string via [joinChannelWithUserAccount].
  Future<void> joinChannel({
    required String channelName,
    required String rtcToken,
    required String userId,
    required bool isVideoCall,
  });

  /// Leaves the active Agora channel.
  Future<void> leaveChannel();

  /// Toggles microphone mute.
  Future<void> toggleMuteAudio(bool isMuted);

  /// Toggles video stream state.
  Future<void> toggleMuteVideo(bool isMuted);

  /// Switches speakerphone on/off.
  Future<void> toggleSpeakerphone(bool isSpeakerOn);

  /// Switches front/rear camera.
  Future<void> switchCamera();

  /// Cleans up resources and disposes the RTC Engine.
  Future<void> dispose();
}
