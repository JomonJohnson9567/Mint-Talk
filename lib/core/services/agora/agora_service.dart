import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import 'i_agora_service.dart';

@LazySingleton(as: IAgoraService)
class AgoraService implements IAgoraService {
  final Logger _logger = Logger();

  RtcEngine? _engine;
  final StreamController<bool> _remoteJoinedController =
      StreamController<bool>.broadcast();
  final StreamController<int?> _remoteUidController =
      StreamController<int?>.broadcast();

  @override
  Stream<bool> get isRemoteUserJoined => _remoteJoinedController.stream;

  @override
  Stream<int?> get remoteUidStream => _remoteUidController.stream;

  @override
  RtcEngine? get engine => _engine;

  @override
  Future<void> initialize(String appId) async {
    if (_engine != null) {
      _logger.d('[AgoraService] Engine already initialized');
      return;
    }

    _logger.i('[AgoraService] Initializing Agora Engine with App ID: $appId');

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _logger.i(
            '✅ [AgoraService] Local user joined channel: ${connection.channelId}',
          );
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          _logger.i(
            '🟢 [AgoraService] Remote user joined channel: $remoteUid',
          );
          if (!_remoteJoinedController.isClosed) {
            _remoteJoinedController.add(true);
          }
          if (!_remoteUidController.isClosed) {
            _remoteUidController.add(remoteUid);
          }
        },
        onUserOffline:
            (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          _logger.w(
            '🔴 [AgoraService] Remote user left channel: $remoteUid (reason: $reason)',
          );
          if (!_remoteJoinedController.isClosed) {
            _remoteJoinedController.add(false);
          }
          if (!_remoteUidController.isClosed) {
            _remoteUidController.add(null);
          }
        },
        onError: (ErrorCodeType err, String msg) {
          _logger.e('❌ [AgoraService] Error [$err]: $msg');
        },
      ),
    );
  }

  @override
  Future<void> joinChannel({
    required String channelName,
    required String rtcToken,
    required String userId,
    required bool isVideoCall,
  }) async {
    if (_engine == null) {
      throw Exception('Agora Engine is not initialized. Call initialize() first.');
    }

    _logger.i(
      '🔌 [AgoraService] Joining channel "$channelName" as userAccount "$userId" (video=$isVideoCall)',
    );

    if (isVideoCall) {
      await [Permission.microphone, Permission.camera].request();
      await _engine!.enableVideo();
      await _engine!.startPreview();
    } else {
      await [Permission.microphone].request();
      await _engine!.enableAudio();
      await _engine!.disableVideo();
    }

    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    await _engine!.joinChannelWithUserAccount(
      token: rtcToken,
      channelId: channelName,
      userAccount: userId,
    );
  }

  @override
  Future<void> leaveChannel() async {
    if (_engine == null) return;
    _logger.d('[AgoraService] Leaving channel...');
    try {
      await _engine!.stopPreview();
      await _engine!.leaveChannel();
    } catch (e) {
      _logger.e('[AgoraService] Error leaving channel: $e');
    }
  }

  @override
  Future<void> toggleMuteAudio(bool isMuted) async {
    if (_engine == null) return;
    _logger.d('[AgoraService] Mute audio: $isMuted');
    await _engine!.muteLocalAudioStream(isMuted);
  }

  @override
  Future<void> toggleMuteVideo(bool isMuted) async {
    if (_engine == null) return;
    _logger.d('[AgoraService] Mute video: $isMuted');
    await _engine!.muteLocalVideoStream(isMuted);
  }

  @override
  Future<void> toggleSpeakerphone(bool isSpeakerOn) async {
    if (_engine == null) return;
    _logger.d('[AgoraService] Speakerphone on: $isSpeakerOn');
    await _engine!.setEnableSpeakerphone(isSpeakerOn);
  }

  @override
  Future<void> switchCamera() async {
    if (_engine == null) return;
    _logger.d('[AgoraService] Switching camera');
    await _engine!.switchCamera();
  }

  @override
  Future<void> dispose() async {
    _logger.d('[AgoraService] Disposing Agora engine.');
    await leaveChannel();
    if (_engine != null) {
      await _engine!.release();
      _engine = null;
    }
    await _remoteJoinedController.close();
    await _remoteUidController.close();
  }
}
