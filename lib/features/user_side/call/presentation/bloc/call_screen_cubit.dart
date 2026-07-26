import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/config/agora/agora_config.dart';
import 'package:mint_talk/config/env/env_config.dart';
import 'package:mint_talk/core/services/agora/i_agora_service.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import '../../domain/entities/call_session_entity.dart';
import '../../domain/usecases/activate_call_usecase.dart';
import '../../domain/usecases/cancel_call_usecase.dart';
import '../../domain/usecases/end_call_usecase.dart';
import '../../domain/usecases/initiate_call_usecase.dart';

part 'call_screen_state.dart';

@injectable
class CallScreenCubit extends Cubit<CallScreenState> {
  final InitiateCallUseCase _initiateCallUseCase;
  final ActivateCallUseCase _activateCallUseCase;
  final EndCallUseCase _endCallUseCase;
  final CancelCallUseCase _cancelCallUseCase;
  final IAgoraService _agoraService;
  final IPresenceSocketService _socketService;
  final TokenManager _tokenManager;
  final EnvConfig _envConfig;

  Timer? _durationTimer;
  StreamSubscription<Map<String, dynamic>>? _socketStatusSub;
  StreamSubscription<bool>? _remoteJoinedSub;
  StreamSubscription<int?>? _remoteUidSub;

  bool _hasActivated = false;

  CallScreenCubit(
    this._initiateCallUseCase,
    this._activateCallUseCase,
    this._endCallUseCase,
    this._cancelCallUseCase,
    this._agoraService,
    this._socketService,
    this._tokenManager,
    this._envConfig,
  ) : super(const CallScreenState());

  /// Initiates an outgoing call from caller to host via socket signaling & REST fallback.
  Future<void> startOutgoingCall({
    required String hostId,
    required String callType,
  }) async {
    emit(state.copyWith(status: CallScreenStatus.initiating));

    // Emit real-time initiate call event over socket
    _socketService.emitInitiateCall(hostId: hostId, callType: callType);

    final result = await _initiateCallUseCase(
      InitiateCallParams(hostId: hostId, callType: callType),
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: CallScreenStatus.failed,
            errorMessage: failure.message,
          ),
        );
      },
      (session) async {
        emit(
          state.copyWith(
            status: CallScreenStatus.ringing,
            session: session,
          ),
        );

        _listenToSocketEvents(session.callId);
        _listenToAgoraRemoteEvents();

        // Connect Agora if channel present
        if (session.agoraChannel != null && session.agoraChannel!.isNotEmpty) {
          await _joinAgoraChannel(session);
        }
      },
    );
  }

  /// Initializes an incoming call accepted by the host.
  Future<void> startIncomingCall(CallSessionEntity session) async {
    emit(
      state.copyWith(
        status: CallScreenStatus.connecting,
        session: session,
      ),
    );

    _listenToSocketEvents(session.callId);
    _listenToAgoraRemoteEvents();

    if (session.agoraChannel != null && session.agoraChannel!.isNotEmpty) {
      await _joinAgoraChannel(session);
    } else {
      await _activateCallSession(session.callId);
    }
  }

  Future<void> _joinAgoraChannel(CallSessionEntity session) async {
    try {
      final channelName = session.agoraChannel;
      if (channelName == null || channelName.isEmpty) {
        debugPrint('⚠️ [CallScreenCubit] Cannot join Agora channel: channelName is null or empty');
        return;
      }

      final agoraConfig = AgoraConfig.fromEnvironment(_envConfig);
      await _agoraService.initialize(agoraConfig.appId);

      // Validate token status for debugging
      final token = await _tokenManager.getValidAccessToken();
      if (token == null) {
        debugPrint('⚠️ [CallScreenCubit] Access token is null when joining Agora channel');
      }

      // Pass callerId / hostId (max 64 chars required by Agora).
      // DO NOT pass the JWT Access Token as userAccount, which causes Agora Error -102.
      String userId = session.callerId;
      if (userId.isEmpty || userId.length > 64) {
        userId = session.hostId.isNotEmpty && session.hostId.length <= 64
            ? session.hostId
            : 'user_${DateTime.now().millisecondsSinceEpoch % 1000000}';
      }
      final rtcToken = session.agoraToken ?? '';

      await _agoraService.joinChannel(
        channelName: channelName,
        rtcToken: rtcToken,
        userId: userId,
        isVideoCall: session.callType.toLowerCase() == 'video',
      );

      // Activation fallback: Trigger activate call session only when connecting (host accepted)
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!isClosed &&
            !_hasActivated &&
            state.session != null &&
            state.status == CallScreenStatus.connecting) {
          debugPrint('⚡ [CallScreenCubit] Activating call session fallback');
          _activateCallSession(state.session!.callId);
        }
      });
    } catch (e) {
      debugPrint('❌ [CallScreenCubit] Agora error: $e');
      if (!_hasActivated &&
          state.session != null &&
          state.status == CallScreenStatus.connecting) {
        _activateCallSession(state.session!.callId);
      }
    }
  }

  void _listenToAgoraRemoteEvents() {
    _remoteJoinedSub = _agoraService.isRemoteUserJoined.listen((isJoined) {
      if (isClosed) return;
      emit(state.copyWith(isRemoteUserJoined: isJoined));

      // Trigger activate call once remote user joins & call is accepted/connecting
      if (isJoined &&
          !_hasActivated &&
          state.session != null &&
          state.status != CallScreenStatus.ringing &&
          state.status != CallScreenStatus.initiating) {
        _activateCallSession(state.session!.callId);
      }
    });

    _remoteUidSub = _agoraService.remoteUidStream.listen((uid) {
      if (isClosed) return;
      emit(state.copyWith(remoteUid: uid));
    });
  }

  Future<void> _activateCallSession(String callId) async {
    if (_hasActivated) return;
    _hasActivated = true;
    final result = await _activateCallUseCase(callId);
    if (isClosed) return;

    result.fold(
      (failure) {
        debugPrint('⚠️ Activate call response: ${failure.message}');
        emit(
          state.copyWith(
            status: CallScreenStatus.active,
          ),
        );
        _startTimer();
      },
      (updatedSession) {
        emit(
          state.copyWith(
            status: CallScreenStatus.active,
            session: updatedSession,
          ),
        );
        _startTimer();
      },
    );
  }

  void _listenToSocketEvents(String callId) {
    _socketService.subscribeCall(callId);
    _socketStatusSub = _socketService.callStatusUpdates.listen((data) {
      if (isClosed) return;
      final status = data['status']?.toString();
      final endReason = data['endReason']?.toString();

      debugPrint('📲 [CallScreenCubit] Socket status update: $status ($endReason)');

      if (status == 'accepted' &&
          (state.status == CallScreenStatus.ringing ||
              state.status == CallScreenStatus.initiating)) {
        final updatedSession = state.session?.copyWith(
          agoraChannel:
              data['agoraChannel']?.toString() ?? state.session?.agoraChannel,
          agoraToken: data['agoraToken']?.toString() ??
              data['token']?.toString() ??
              state.session?.agoraToken,
          status: 'accepted',
        );
        emit(state.copyWith(
          status: CallScreenStatus.connecting,
          session: updatedSession ?? state.session,
        ));

        if (updatedSession != null) {
          _joinAgoraChannel(updatedSession);
        }
      } else if (status == 'active' && state.status != CallScreenStatus.active) {
        _hasActivated = true;
        _startTimer();
        emit(state.copyWith(
          status: CallScreenStatus.active,
          session: _buildSessionFromSocket(data) ?? state.session,
        ));
      } else if (status == 'ended' || status == 'rejected' || status == 'missed') {
        _handleCallEnded(data);
      } else if (status == 'insufficient_balance' || endReason == 'insufficient_balance') {
        _handleInsufficientBalance(data);
      }
    });
  }

  void _startTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) return;
      emit(state.copyWith(durationSeconds: state.durationSeconds + 1));
    });
  }

  void toggleMuteAudio() {
    final nextMute = !state.isMuted;
    emit(state.copyWith(isMuted: nextMute));
    _agoraService.toggleMuteAudio(nextMute);
  }

  void toggleMuteVideo() {
    final nextVideoMute = !state.isVideoMuted;
    emit(state.copyWith(isVideoMuted: nextVideoMute));
    _agoraService.toggleMuteVideo(nextVideoMute);
  }

  void toggleSpeakerphone() {
    final nextSpeaker = !state.isSpeakerOn;
    emit(state.copyWith(isSpeakerOn: nextSpeaker));
    _agoraService.toggleSpeakerphone(nextSpeaker);
  }

  void switchCamera() {
    _agoraService.switchCamera();
  }

  Future<void> endCall() async {
    final session = state.session;
    final currentStatus = state.status;

    if (state.isCallEnded) {
      return;
    }

    emit(state.copyWith(status: CallScreenStatus.ended));

    if (session != null) {
      if (currentStatus == CallScreenStatus.ringing ||
          currentStatus == CallScreenStatus.initiating) {
        _socketService.emitCancelCall(session.callId);
        await _cancelCallUseCase(session.callId);
      } else if (currentStatus == CallScreenStatus.active ||
          currentStatus == CallScreenStatus.connecting) {
        _socketService.emitEndCall(session.callId);
        await _endCallUseCase(session.callId);
      }
    }

    _cleanupAndCloseScreen();
  }

  void _handleCallEnded(Map<String, dynamic> data) {
    _stopTimer();
    final updatedSession = _buildSessionFromSocket(data);
    emit(
      state.copyWith(
        status: CallScreenStatus.ended,
        session: updatedSession ?? state.session,
      ),
    );
    _agoraService.leaveChannel();
  }

  void _handleInsufficientBalance(Map<String, dynamic> data) {
    _stopTimer();
    final updatedSession = _buildSessionFromSocket(data);
    emit(
      state.copyWith(
        status: CallScreenStatus.insufficientBalance,
        session: updatedSession ?? state.session,
        errorMessage: 'Call ended: insufficient balance',
      ),
    );
    _agoraService.leaveChannel();
  }

  CallSessionEntity? _buildSessionFromSocket(Map<String, dynamic> data) {
    final current = state.session;
    if (current == null) return null;
    return CallSessionEntity(
      callId: data['callId']?.toString() ?? current.callId,
      agoraChannel: data['agoraChannel']?.toString() ?? current.agoraChannel,
      agoraToken: data['agoraToken']?.toString() ??
          data['rtcToken']?.toString() ??
          data['token']?.toString() ??
          current.agoraToken,
      status: data['status']?.toString() ?? current.status,
      callType: data['callType']?.toString() ?? current.callType,
      duration: data['duration'] is int
          ? data['duration']
          : (int.tryParse(data['duration']?.toString() ?? '') ?? state.durationSeconds),
      billedMinutes: data['billedMinutes'] is int
          ? data['billedMinutes']
          : (int.tryParse(data['billedMinutes']?.toString() ?? '') ?? 0),
      totalPointsDebited: data['totalPointsDebited'] is int
          ? data['totalPointsDebited']
          : (int.tryParse(data['totalPointsDebited']?.toString() ?? '') ?? 0),
      ratePerMinute: current.ratePerMinute,
      endReason: data['endReason']?.toString() ?? current.endReason,
      hostId: data['hostId']?.toString() ?? current.hostId,
      callerId: data['callerId']?.toString() ?? current.callerId,
    );
  }

  void _stopTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void _cleanupAndCloseScreen() {
    _stopTimer();
    if (state.session != null) {
      _socketService.unsubscribeCall(state.session!.callId);
    }
    _socketStatusSub?.cancel();
    _remoteJoinedSub?.cancel();
    _remoteUidSub?.cancel();
    _agoraService.dispose();
  }

  @override
  Future<void> close() {
    _cleanupAndCloseScreen();
    return super.close();
  }
}
