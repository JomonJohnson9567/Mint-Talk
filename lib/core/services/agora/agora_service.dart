import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import 'i_agora_service.dart';

@LazySingleton(as: IAgoraService)
class AgoraService implements IAgoraService {
  final Logger _logger = Logger();

  RtcEngine? _engine;
  StreamController<AgoraCallEvent>? _eventController;
  bool _isDisposing = false;
  bool _isJoining = false;
  bool _isJoined = false;

  @override
  Stream<AgoraCallEvent> get events =>
      _eventController?.stream ?? const Stream.empty();

  @override
  RtcEngine? get engine => _engine;

  void _addEvent(AgoraCallEvent event) {
    if (_eventController != null && !_eventController!.isClosed) {
      _eventController!.add(event);
    }
  }

  @override
  Future<void> initialize(String appId) async {
    while (_isDisposing) {
      _logger.d('[AgoraService] Engine is currently disposing, waiting to initialize...');
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (_engine != null) {
      _logger.d('[AgoraService] Engine already initialized');
      return;
    }

    _eventController ??= StreamController<AgoraCallEvent>.broadcast();

    _logger.i('[AgoraService] Initializing Agora Engine with App ID: $appId');

    try {
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
            _isJoining = false;
            _isJoined = true;
            _addEvent(const AgoraLocalJoinSuccess());
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            _logger.i(
              '🟢 [AgoraService] Remote user joined channel: $remoteUid',
            );
            _addEvent(AgoraRemoteUserJoined(remoteUid));
          },
          onUserOffline:
              (RtcConnection connection, int remoteUid
              , UserOfflineReasonType reason) {
            _logger.w(
              '🔴 [AgoraService] Remote user left channel: $remoteUid (reason: $reason)',
            );
            _addEvent(AgoraRemoteUserLeft(remoteUid, reason));
          },
          onNetworkQuality: (
            RtcConnection connection,
            int remoteUid,
            QualityType txQuality,
            QualityType rxQuality,
          ) {
            // High-frequency (~2s/uid) — no logging here, only on real
            // threshold changes, handled upstream in the Cubit.
            _addEvent(
              AgoraNetworkQualityChanged(
                remoteUid: remoteUid,
                txQuality: txQuality,
                rxQuality: rxQuality,
              ),
            );
          },
          onConnectionStateChanged: (
            RtcConnection connection,
            ConnectionStateType state,
            ConnectionChangedReasonType reason,
          ) {
            _logger.i(
              '🔌 [AgoraService] Connection state changed: $state (reason: $reason)',
            );
            if (state == ConnectionStateType.connectionStateFailed ||
                state == ConnectionStateType.connectionStateDisconnected) {
              _isJoining = false;
              _isJoined = false;
            }
            _addEvent(AgoraConnectionChanged(state: state, reason: reason));
          },
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            _logger.w('⚠️ [AgoraService] Token will expire soon');
            _addEvent(const AgoraTokenWillExpire());
          },
          onRequestToken: (RtcConnection connection) {
            _logger.w('⚠️ [AgoraService] Token expired, requesting new token');
            _addEvent(const AgoraTokenExpired());
          },
          onError: (ErrorCodeType err, String msg) {
            _logger.e('❌ [AgoraService] Error [$err]: $msg');
            _addEvent(AgoraCallError(code: err, message: msg));
          },
        ),
      );
    } catch (e) {
      _logger.e('❌ [AgoraService] Initialization failed: $e');
      throw AgoraInitializationException('Failed to initialize Agora Engine: $e');
    }
  }

  @override
  Future<void> joinChannel({
    required String channelName,
    required String rtcToken,
    required String userAccount,
    required bool isVideoCall,
  }) async {
    if (_engine == null) {
      throw const AgoraJoinException('Agora Engine is not initialized. Call initialize() first.');
    }

    final sanitizedToken = _sanitizeToken(rtcToken);
    final sanitizedChannel = channelName.trim();
    final sanitizedUserAccount = userAccount.trim();

    if (sanitizedChannel.isEmpty) {
      throw const AgoraJoinException('Agora channel name is empty.');
    }
    if (sanitizedUserAccount.isEmpty) {
      throw const AgoraJoinException('Agora user account is empty.');
    }

    if (_isJoining || _isJoined) {
      _logger.w('⚠️ [AgoraService] Join channel request ignored. isJoining=$_isJoining, isJoined=$_isJoined');
      return;
    }

    _isJoining = true;

    if (kDebugMode) {
      _logger.i(
        '🔌 [AgoraService] Joining channel "$sanitizedChannel" with userAccount "$sanitizedUserAccount"\n'
        '   → (video=$isVideoCall, hasToken=${sanitizedToken.isNotEmpty})',
      );
    }

    try {
      if (isVideoCall) {
        await _engine!.enableAudio();
        await _engine!.enableVideo();
        await _engine!.enableLocalVideo(true);
        await _engine!.startPreview();
      } else {
        await _engine!.enableAudio();
        await _engine!.disableVideo();
      }

      await _engine!.joinChannelWithUserAccount(
        token: sanitizedToken,
        channelId: sanitizedChannel,
        userAccount: sanitizedUserAccount,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishMicrophoneTrack: true,
          publishCameraTrack: isVideoCall,
          autoSubscribeAudio: true,
          autoSubscribeVideo: isVideoCall,
        ),
      );
    } catch (e) {
      _isJoining = false;
      _logger.e('❌ [AgoraService] joinChannel failed: $e');
      throw AgoraJoinException('Failed to join channel: $e');
    }
  }

  String _sanitizeToken(String token) {
    final trimmed = token.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null' || trimmed.toLowerCase() == 'undefined') {
      return '';
    }
    return trimmed;
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
    } finally {
      _isJoining = false;
      _isJoined = false;
    }
  }

  @override
  Future<void> renewToken(String token) async {
    if (_engine == null) return;
    final sanitizedToken = _sanitizeToken(token);
    if (kDebugMode) {
      _logger.i('[AgoraService] Renewing token (hasToken=${sanitizedToken.isNotEmpty})');
    }
    try {
      await _engine!.renewToken(sanitizedToken);
    } catch (e) {
      _logger.e('[AgoraService] Error renewing token: $e');
      throw AgoraTokenException('Failed to renew Agora token: $e');
    }
  }

  @override
  Future<void> toggleMuteAudio(bool isMuted) async {
    if (_engine == null) return;
    _logger.d('[AgoraService] Mute audio: $isMuted');
    try {
      await _engine!.muteLocalAudioStream(isMuted);
    } catch (e) {
      _logger.w('⚠️ muteLocalAudioStream failed: $e');
    }
  }

  @override
  Future<void> toggleMuteVideo(bool isMuted) async {
    if (_engine == null) return;
    _logger.d('[AgoraService] Mute video: $isMuted');
    try {
      await _engine!.muteLocalVideoStream(isMuted);
    } catch (e) {
      _logger.w('⚠️ muteLocalVideoStream failed: $e');
    }
  }

  @override
  Future<void> toggleSpeakerphone(bool isSpeakerOn) async {
    if (_engine == null) return;
    _logger.d('[AgoraService] Speakerphone on: $isSpeakerOn');
    try {
      await _engine!.setEnableSpeakerphone(isSpeakerOn);
    } catch (e) {
      _logger.w('⚠️ setEnableSpeakerphone failed: $e');
    }
  }

  @override
  Future<void> switchCamera() async {
    if (_engine == null) return;
    _logger.d('[AgoraService] Switching camera');
    try {
      await _engine!.switchCamera();
    } catch (e) {
      _logger.w('⚠️ switchCamera failed: $e');
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposing) return;
    _isDisposing = true;
    _logger.d('[AgoraService] Disposing Agora engine.');
    try {
      await leaveChannel();
      if (_engine != null) {
        await _engine!.release();
        _engine = null;
      }
      await _eventController?.close();
      _eventController = null;
    } finally {
      _isDisposing = false;
    }
  }
}
