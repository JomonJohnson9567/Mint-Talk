import 'dart:async';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import 'call_audio_route.dart';
import 'i_agora_service.dart';

@LazySingleton(as: IAgoraService)
class AgoraService implements IAgoraService {
  final Logger _logger = Logger();

  RtcEngine? _engine;
  StreamController<AgoraCallEvent>? _eventController;
  bool _isDisposing = false;
  bool _isJoining = false;
  bool _isJoined = false;

  /// Local mic is encoding. Tracked across the join because Agora usually
  /// reports encoding *before* onJoinChannelSuccess.
  bool _isLocalAudioEncoding = false;

  // Bounds every native engine call made during teardown. Without this, a
  // hung stopPreview()/leaveChannel()/release() (seen in practice on some
  // devices) leaves `_isDisposing` stuck true forever, which then wedges
  // initialize()'s wait loop below and permanently freezes every call after
  // it at the "initializing" stage — since this service is a
  // process-lifetime singleton reused across calls, not a fresh instance.
  static const _nativeCallTimeout = Duration(seconds: 3);

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
      _logger.d(
        '[AgoraService] Engine is currently disposing, waiting to initialize...',
      );
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
            if (_isLocalAudioEncoding) _addEvent(const AgoraLocalAudioPublished());
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            _logger.i(
              '🟢 [AgoraService] Remote user joined channel: $remoteUid',
            );
            _addEvent(AgoraRemoteUserJoined(remoteUid));
          },
          onUserOffline:
              (
                RtcConnection connection,
                int remoteUid,
                UserOfflineReasonType reason,
              ) {
                _logger.w(
                  '🔴 [AgoraService] Remote user left channel: $remoteUid (reason: $reason)',
                );
                _addEvent(AgoraRemoteUserLeft(remoteUid, reason));
              },
          onNetworkQuality:
              (
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
          onConnectionStateChanged:
              (
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
          onFirstLocalAudioFramePublished: (RtcConnection connection, int elapsed) {
            _logger.i(
              '🎙️ [AgoraService] First local audio frame published (${elapsed}ms)',
            );
            _addEvent(const AgoraLocalAudioPublished());
          },
          onRemoteAudioStateChanged:
              (
                RtcConnection connection,
                int remoteUid,
                RemoteAudioState state,
                RemoteAudioStateReason reason,
                int elapsed,
              ) {
                final isReceiving =
                    state == RemoteAudioState.remoteAudioStateDecoding ||
                    (state == RemoteAudioState.remoteAudioStateStopped &&
                        reason ==
                            RemoteAudioStateReason
                                .remoteAudioReasonRemoteMuted);
                if (isReceiving) {
                  _logger.i(
                    '🔊 [AgoraService] Receiving remote audio: $remoteUid ($state)',
                  );
                  _addEvent(AgoraRemoteAudioReceived(remoteUid));
                }
              },
          onLocalAudioStateChanged:
              (
                RtcConnection connection,
                LocalAudioStreamState state,
                LocalAudioStreamReason reason,
              ) {
                _isLocalAudioEncoding =
                    state ==
                    LocalAudioStreamState.localAudioStreamStateEncoding;
                if (state ==
                    LocalAudioStreamState.localAudioStreamStateFailed) {
                  _logger.e('❌ [AgoraService] Local audio failed: $reason');
                  _addEvent(
                    AgoraLocalMediaFailed('Microphone failed ($reason)'),
                  );
                } else if (_isLocalAudioEncoding && _isJoined) {
                  // Joined with publishMicrophoneTrack + encoding is publishing.
                  // Covers a mic muted before the first frame went out, where
                  // onFirstLocalAudioFramePublished may never fire. (Encoding
                  // seen before the join is replayed from onJoinChannelSuccess.)
                  _addEvent(const AgoraLocalAudioPublished());
                }
              },
          onLocalVideoStateChanged:
              (
                VideoSourceType source,
                LocalVideoStreamState state,
                LocalVideoStreamReason reason,
              ) {
                if (state ==
                    LocalVideoStreamState.localVideoStreamStateFailed) {
                  _logger.e('❌ [AgoraService] Local video failed: $reason');
                  _addEvent(AgoraLocalMediaFailed('Camera failed ($reason)'));
                }
              },
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            _logger.w('⚠️ [AgoraService] Token will expire soon');
            _addEvent(const AgoraTokenWillExpire());
          },
          onRequestToken: (RtcConnection connection) {
            _logger.w('⚠️ [AgoraService] Token expired, requesting new token');
            _addEvent(const AgoraTokenExpired());
          },
          onAudioRoutingChanged: (int routing) {
            final route = callAudioRouteFromAgora(routing);
            _logger.d(
              '[AgoraService] Audio routing changed: $routing → $route',
            );
            if (route != null) _addEvent(AgoraAudioRouteChanged(route));
          },
          onError: (ErrorCodeType err, String msg) {
            _logger.e('❌ [AgoraService] Error [$err]: $msg');
            _addEvent(AgoraCallError(code: err, message: msg));
          },
        ),
      );
    } catch (e) {
      _logger.e('❌ [AgoraService] Initialization failed: $e');
      throw AgoraInitializationException(
        'Failed to initialize Agora Engine: $e',
      );
    }
  }

  @override
  Future<void> joinChannel({
    required String channelName,
    required String rtcToken,
    required int uid,
    required bool isVideoCall,
  }) async {
    if (_engine == null) {
      throw const AgoraJoinException(
        'Agora Engine is not initialized. Call initialize() first.',
      );
    }

    final sanitizedToken = _sanitizeToken(rtcToken);
    final sanitizedChannel = channelName.trim();

    if (sanitizedChannel.isEmpty) {
      throw const AgoraJoinException('Agora channel name is empty.');
    }
    if (uid <= 0) {
      throw AgoraJoinException('Invalid Agora uid: $uid');
    }

    if (_isJoining || _isJoined) {
      _logger.w(
        '⚠️ [AgoraService] Join channel request ignored. isJoining=$_isJoining, isJoined=$_isJoined',
      );
      return;
    }

    _isJoining = true;

    if (kDebugMode) {
      _logger.i(
        '🔌 [AgoraService] Joining channel "$sanitizedChannel" with uid $uid\n'
        '   → (video=$isVideoCall, hasToken=${sanitizedToken.isNotEmpty})',
      );
    }

    try {
      // Video calls start on the loudspeaker, audio calls on the earpiece.
      // A connected Bluetooth/wired headset still takes priority.
      await _engine!.setDefaultAudioRouteToSpeakerphone(isVideoCall);

      if (isVideoCall) {
        await _engine!.enableAudio();
        await _engine!.enableVideo();
        await _engine!.enableLocalVideo(true);
        await _engine!.startPreview();
      } else {
        await _engine!.enableAudio();
        await _engine!.disableVideo();
      }

      await _engine!.joinChannel(
        token: sanitizedToken,
        channelId: sanitizedChannel,
        uid: uid,
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
    if (trimmed.isEmpty ||
        trimmed.toLowerCase() == 'null' ||
        trimmed.toLowerCase() == 'undefined') {
      return '';
    }
    return trimmed;
  }

  @override
  Future<void> leaveChannel() async {
    if (_engine == null) return;
    _logger.d('[AgoraService] Leaving channel...');
    try {
      // Isolated from leaveChannel() below: audio-only calls never call
      // enableVideo()/startPreview() (see joinChannel, which calls
      // disableVideo() instead), so stopPreview() can throw here since the
      // video module was never active. That must never block the
      // leaveChannel() call below — that's the call that actually notifies
      // Agora's servers this user left voluntarily
      // (UserOfflineReasonType.userOfflineQuit). If it's skipped, the peer
      // never gets the graceful "quit" signal and falls back to the much
      // slower network-drop timeout detection instead.
      await _engine!.stopPreview().timeout(_nativeCallTimeout);
    } catch (e) {
      _logger.w(
        '[AgoraService] stopPreview failed (expected for audio-only calls): $e',
      );
    }
    try {
      await _engine!.leaveChannel().timeout(_nativeCallTimeout);
    } catch (e) {
      _logger.e('[AgoraService] Error leaving channel: $e');
    } finally {
      _isJoining = false;
      _isJoined = false;
      _isLocalAudioEncoding = false;
    }
  }

  @override
  Future<void> renewToken(String token) async {
    if (_engine == null) return;
    final sanitizedToken = _sanitizeToken(token);
    if (kDebugMode) {
      _logger.i(
        '[AgoraService] Renewing token (hasToken=${sanitizedToken.isNotEmpty})',
      );
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
  Future<void> setAudioRoute(CallAudioRoute route) async {
    if (_engine == null) return;
    _logger.d('[AgoraService] Set audio route: $route');
    try {
      if (Platform.isAndroid) {
        // Agora: don't mix this with setEnableSpeakerphone on Android.
        await _engine!.setRouteInCommunicationMode(
          agoraCommunicationRouteFor(route),
        );
        return;
      }

      await _engine!.setEnableSpeakerphone(route == CallAudioRoute.speaker);
      if (Platform.isIOS && route != CallAudioRoute.speaker) {
        await _selectIosInput(route);
      }
    } catch (e) {
      _logger.w('⚠️ setAudioRoute($route) failed: $e');
    }
  }

  /// On iOS, with the speaker override off, the output follows the
  /// preferred input: the built-in mic means the receiver (earpiece), a
  /// Bluetooth HFP input means that headset.
  Future<void> _selectIosInput(CallAudioRoute route) async {
    final wanted = switch (route) {
      CallAudioRoute.bluetooth => const {AVAudioSessionPort.bluetoothHfp},
      CallAudioRoute.wiredHeadset => const {AVAudioSessionPort.headsetMic},
      _ => const {AVAudioSessionPort.builtInMic},
    };
    final session = AVAudioSession();
    final inputs = await session.availableInputs;
    final port = inputs.where((p) => wanted.contains(p.portType)).firstOrNull;
    if (port == null) {
      _logger.w('⚠️ [AgoraService] No iOS input available for $route');
      return;
    }
    await session.setPreferredInput(port);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposing) return;
    _isDisposing = true;
    _logger.d('[AgoraService] Disposing Agora engine.');
    try {
      await leaveChannel();
      if (_engine != null) {
        try {
          await _engine!.release().timeout(_nativeCallTimeout);
        } catch (e) {
          _logger.e('[AgoraService] Error releasing engine: $e');
        }
        // Drop the reference regardless of whether release() above
        // succeeded, failed, or timed out — a zombie engine reused by the
        // next initialize() is worse than a leaked native handle.
        _engine = null;
      }
      await _eventController?.close();
      _eventController = null;
    } finally {
      _isDisposing = false;
    }
  }
}
