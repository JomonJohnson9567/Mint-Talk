import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:mint_talk/config/agora/agora_config.dart';
import 'package:mint_talk/config/env/env_config.dart';
import 'package:mint_talk/core/services/agora/i_agora_service.dart';
import 'package:mint_talk/core/services/connectivity/connectivity_service.dart';
import 'package:mint_talk/core/services/permissions/call_permission_service.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';
import '../../data/models/incoming_call_payload_dto.dart';
import '../../domain/entities/call_participant_role.dart';
import '../../domain/entities/call_session_entity.dart';
import '../../domain/entities/call_socket_event.dart';
import '../../domain/entities/call_type.dart';
import '../../domain/repositories/i_call_repository.dart';
import '../../domain/usecases/accept_call_usecase.dart';
import '../../domain/usecases/activate_call_usecase.dart';
import '../../domain/usecases/cancel_call_usecase.dart';
import '../../domain/usecases/end_call_usecase.dart';
import '../../domain/usecases/initiate_call_usecase.dart';
import 'call_duration_ticker.dart';
import 'call_media_controls.dart';

part 'call_screen_state.dart';

/// Manages the full call lifecycle state for both caller (user) and host.
///
/// Flow (Caller):
///   startOutgoingCall() → HTTP initiateCall → ringing
///   ← socket call_accepted → connecting → joinAgoraChannel
///   ← Agora remoteUserJoined → HTTP activateCall → active
///   endCall() → HTTP endCall → ended
///
/// Flow (Host, session already known):
///   startIncomingCall(session) → connecting → joinAgoraChannel
///   ← Agora remoteUserJoined → HTTP activateCall → active
///   endCall() → HTTP endCall → ended
///
/// Flow (Host, accepting from the ringing overlay):
///   acceptIncomingCall(payload) → connecting → HTTP acceptCall → joinAgoraChannel
///   ← Agora remoteUserJoined → HTTP activateCall → active
///   endCall() → HTTP endCall → ended
///
/// Rule: HTTP for all state-changing actions. WebSocket for server-push events only.
@injectable
class CallScreenCubit extends Cubit<CallScreenState> {
  final InitiateCallUseCase _initiateCallUseCase;
  final AcceptCallUseCase _acceptCallUseCase;
  final ActivateCallUseCase _activateCallUseCase;
  final EndCallUseCase _endCallUseCase;
  final CancelCallUseCase _cancelCallUseCase;
  final IAgoraService _agoraService;
  final ICallRepository _callRepository;
  final EnvConfig _envConfig;
  final ICallPermissionService _permissionService;
  final AuthRepository _authRepository;
  final IConnectivityService _connectivityService;
  final IPresenceSocketService _presenceSocketService;

  late final CallMediaControls _mediaControls = CallMediaControls(_agoraService);
  final CallDurationTicker _durationTicker = CallDurationTicker();
  Timer? _joinTimeoutTimer;
  Timer? _remoteReconnectTimer;
  Timer? _localMidCallReconnectTimer;
  Timer? _controlsAutoHideTimer;
  StreamSubscription<CallSocketEvent>? _socketEventSub;
  StreamSubscription<AgoraCallEvent>? _agoraEventSub;
  StreamSubscription<bool>? _connectivitySub;

  NetworkQualityLevel _lastEmittedLocalQuality = NetworkQualityLevel.unknown;
  NetworkQualityLevel _lastEmittedRemoteQuality = NetworkQualityLevel.unknown;

  CallParticipantRole? _localRole;
  bool _joinRequested = false;

  /// True only once POST /activate has actually succeeded. Billing starts
  /// server-side on that success, so this must never be set ahead of it —
  /// setting it optimistically before the call resolves would permanently
  /// abandon activation (and therefore billing) for the rest of this call
  /// if that one attempt happened to fail, even though Agora media keeps
  /// working fine on its own separate pipeline and the call feels
  /// completely normal to both participants.
  bool _hasActivated = false;

  /// Guards against a second, concurrent activate attempt starting while
  /// one is already in flight (e.g. a duplicate AgoraRemoteUserJoined
  /// callback) — separate from [_hasActivated] so a failed attempt can
  /// still be retried.
  bool _isActivating = false;

  /// Number of retry attempts made after a failed activate call.
  int _activateRetryAttempts = 0;
  static const int _maxActivateRetries = 4;
  Timer? _activateRetryTimer;

  /// Guards against duplicate termination handling.
  /// Set when the call is terminated (from socket or user action).
  bool _hasTerminated = false;

  /// True when termination was server-driven (socket event).
  /// Prevents redundant HTTP /end call from endCall() in that case.
  bool _serverEndedCall = false;

  /// Guards a single automatic rejoin attempt when Agora reports
  /// [ConnectionStateType.connectionStateFailed] (e.g. a brief network blip
  /// while the screen was off). Only if the retry also fails do we actually
  /// end the call — it should never drop just because of a transient hiccup.
  bool _hasRetriedConnectionFailure = false;

  CallScreenCubit(
    this._initiateCallUseCase,
    this._acceptCallUseCase,
    this._activateCallUseCase,
    this._endCallUseCase,
    this._cancelCallUseCase,
    this._agoraService,
    this._callRepository,
    this._envConfig,
    this._permissionService,
    this._authRepository,
    this._connectivityService,
    this._presenceSocketService,
  ) : super(const CallScreenState());

  /// Exposes the live Agora engine for widgets that need to attach a video
  /// view (e.g. [AgoraVideoView]) — the cubit already owns [IAgoraService],
  /// so this avoids the UI resolving it from the service locator directly.
  RtcEngine? get agoraEngine => _agoraService.engine;

  // ---------------------------------------------------------------------------
  // Phase 1: Call Initiation (Caller side)
  // ---------------------------------------------------------------------------

  /// Initiates an outgoing call via HTTP REST only.
  /// The backend validates, creates the Agora channel/token, saves the call
  /// as RINGING, and pushes incoming_call to the host over WebSocket.
  Future<void> startOutgoingCall({
    required String hostId,
    required CallType callType,
    String displayName = '',
    String? avatarUrl,
  }) async {
    _cleanupResources();
    // Keep the CPU (and screen, for video calls) awake for the whole call so
    // it survives the phone being set face-down / screen timing out, the
    // way WhatsApp/Instagram calls do — released again in _cleanupResources.
    unawaited(WakelockPlus.enable());

    // Reset state completely to initiating status
    emit(
      CallScreenState(
        status: CallScreenStatus.initiating,
        mediaStatus: CallMediaStatus.idle,
        displayName: displayName,
        avatarUrl: avatarUrl,
        isHost: false,
      ),
    );

    _localRole = CallParticipantRole.caller;
    _hasTerminated = false;
    _serverEndedCall = false;
    _hasActivated = false;
    _isActivating = false;
    _activateRetryAttempts = 0;
    _activateRetryTimer?.cancel();
    _activateRetryTimer = null;
    _joinRequested = false;
    _hasRetriedConnectionFailure = false;
    _lastEmittedLocalQuality = NetworkQualityLevel.unknown;
    _lastEmittedRemoteQuality = NetworkQualityLevel.unknown;

    final result = await _initiateCallUseCase(
      InitiateCallParams(hostId: hostId, callType: callType),
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: CallScreenStatus.failed,
            mediaStatus: CallMediaStatus.failed,
            errorMessage: failure.message,
          ),
        );
      },
      (session) {
        final effectiveSession = session.callType != callType
            ? session.copyWith(callType: callType)
            : session;

        emit(
          state.copyWith(status: CallScreenStatus.ringing, session: effectiveSession),
        );
        // Subscribe to server-pushed socket events for this call
        _callRepository.subscribeCallSocket(effectiveSession.callId);
        _listenToSocketEvents();

        // Caller already has Agora channel/token from initiate response — join now
        if (effectiveSession.agoraChannel?.isNotEmpty == true) {
          _connectToAgora(effectiveSession);
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Phase 2: Host Accepts (Host side entry point)
  // ---------------------------------------------------------------------------

  /// Entry point when the host taps Accept on the ringing overlay. Unlike
  /// [startIncomingCall], the call hasn't been accepted yet — this method
  /// performs the HTTP accept call itself, but only after the caller has
  /// already navigated to [CallScreen] and it's on screen showing its own
  /// `connecting` UI. This mirrors [startOutgoingCall]'s "navigate first, do
  /// the network I/O inside the already-visible screen" pattern instead of
  /// blocking the ringing overlay on the round trip.
  Future<void> acceptIncomingCall(
    IncomingCallPayloadDto payload, {
    String displayName = '',
    String? avatarUrl,
  }) async {
    _cleanupResources();
    unawaited(WakelockPlus.enable());

    emit(
      CallScreenState(
        status: CallScreenStatus.connecting,
        mediaStatus: CallMediaStatus.idle,
        displayName: displayName,
        avatarUrl: avatarUrl,
        isHost: true,
      ),
    );

    _localRole = CallParticipantRole.host;
    _hasTerminated = false;
    _serverEndedCall = false;
    _hasActivated = false;
    _isActivating = false;
    _activateRetryAttempts = 0;
    _activateRetryTimer?.cancel();
    _activateRetryTimer = null;
    _joinRequested = false;
    _hasRetriedConnectionFailure = false;
    _lastEmittedLocalQuality = NetworkQualityLevel.unknown;
    _lastEmittedRemoteQuality = NetworkQualityLevel.unknown;

    final result = await _acceptCallUseCase(payload.callId);
    if (isClosed) return;

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: CallScreenStatus.failed,
            mediaStatus: CallMediaStatus.failed,
            errorMessage: failure.message,
          ),
        );
      },
      (session) {
        final effectiveSession = session.callType != payload.callType
            ? session.copyWith(callType: payload.callType)
            : session;

        emit(state.copyWith(session: effectiveSession));

        _callRepository.subscribeCallSocket(effectiveSession.callId);
        _listenToSocketEvents();

        if (effectiveSession.agoraChannel?.isNotEmpty == true) {
          _connectToAgora(effectiveSession);
        }
      },
    );
  }

  /// Entry point when the host has already accepted via HTTP and navigates
  /// to the call screen with the session returned by acceptCall().
  Future<void> startIncomingCall(
    CallSessionEntity session, {
    String displayName = '',
    String? avatarUrl,
  }) async {
    _cleanupResources();
    unawaited(WakelockPlus.enable());

    emit(
      CallScreenState(
        status: CallScreenStatus.connecting,
        mediaStatus: CallMediaStatus.idle,
        session: session,
        displayName: displayName,
        avatarUrl: avatarUrl,
        isHost: true,
      ),
    );

    _localRole = CallParticipantRole.host;
    _hasTerminated = false;
    _serverEndedCall = false;
    _hasActivated = false;
    _isActivating = false;
    _activateRetryAttempts = 0;
    _activateRetryTimer?.cancel();
    _activateRetryTimer = null;
    _joinRequested = false;
    _hasRetriedConnectionFailure = false;
    _lastEmittedLocalQuality = NetworkQualityLevel.unknown;
    _lastEmittedRemoteQuality = NetworkQualityLevel.unknown;

    _callRepository.subscribeCallSocket(session.callId);
    _listenToSocketEvents();

    if (session.agoraChannel?.isNotEmpty == true) {
      _connectToAgora(session);
    }
  }

  // ---------------------------------------------------------------------------
  // Agora Connection Single Entry Point
  // ---------------------------------------------------------------------------

  Future<void> _connectToAgora(CallSessionEntity session, {bool forceTokenUpdate = false}) async {
    if (_joinRequested && !forceTokenUpdate) return;
    _joinRequested = true;

    emit(state.copyWith(mediaStatus: CallMediaStatus.requestingPermissions));

    final isVideo = session.callType.isVideo;
    final permissionResult = await _permissionService.requestPermissions(
      isVideoCall: isVideo,
    );

    if (isClosed) return;

    if (!permissionResult.isGranted) {
      String errorMsg = 'Required permissions were denied.';
      if (permissionResult.failure == CallPermissionFailure.microphoneDenied ||
          permissionResult.failure ==
              CallPermissionFailure.microphonePermanentlyDenied) {
        errorMsg = 'Microphone permission is required to make calls.';
      } else if (permissionResult.failure ==
              CallPermissionFailure.cameraDenied ||
          permissionResult.failure ==
              CallPermissionFailure.cameraPermanentlyDenied) {
        errorMsg = 'Camera permission is required for video calls.';
      }

      emit(
        state.copyWith(
          status: CallScreenStatus.failed,
          mediaStatus: CallMediaStatus.failed,
          errorMessage: errorMsg,
        ),
      );
      _joinRequested = false;
      return;
    }

    emit(state.copyWith(mediaStatus: CallMediaStatus.initializing));

    try {
      final agoraConfig = AgoraConfig.fromEnvironment(_envConfig);
      await _agoraService.initialize(agoraConfig.appId);

      if (isClosed) return;

      final localUserAccount = await _resolveLocalUserAccount(session);

      _subscribeToAgoraEvents();
      _subscribeToConnectivity();

      emit(state.copyWith(mediaStatus: CallMediaStatus.joining));

      _startJoinTimeout();

      await _agoraService.joinChannel(
        channelName: session.agoraChannel ?? '',
        rtcToken: session.agoraToken ?? '',
        userAccount: localUserAccount,
        isVideoCall: isVideo,
      );

      appLogger.d('✅ [CallCubit] Join channel request initiated successfully');
    } catch (e) {
      appLogger.d('❌ [CallCubit] Agora join failed: $e');
      emit(
        state.copyWith(
          status: CallScreenStatus.failed,
          mediaStatus: CallMediaStatus.failed,
          errorMessage: e.toString(),
        ),
      );
      _joinRequested = false;
      _cleanupResources();
    }
  }

  Future<String> _resolveLocalUserAccount(CallSessionEntity session) async {
    // Try to resolve from secure storage first as it is the most reliable source for the local user ID
    final loggedInUserId = await _authRepository.getUserId();
    if (loggedInUserId != null && loggedInUserId.trim().isNotEmpty) {
      return loggedInUserId.trim();
    }

    final role = _localRole;
    if (role == null) {
      throw Exception('Local call participant role is not initialized.');
    }

    final userAccount = switch (role) {
      CallParticipantRole.caller => session.callerId,
      CallParticipantRole.host => session.hostId,
    };

    final sanitizedUserAccount = userAccount.trim();
    if (sanitizedUserAccount.isEmpty) {
      throw Exception('Local Agora user account identifier is missing.');
    }

    return sanitizedUserAccount;
  }

  void _subscribeToAgoraEvents() {
    _agoraEventSub?.cancel();
    _agoraEventSub = _agoraService.events.listen((event) {
      if (isClosed) return;

      switch (event) {
        case AgoraLocalJoinSuccess():
          emit(state.copyWith(mediaStatus: CallMediaStatus.waitingForRemote));
          break;

        case AgoraRemoteUserJoined(:final remoteUid):
          _joinTimeoutTimer?.cancel();

          // Remote rejoined after a network-drop grace period — clear the
          // "waiting to reconnect" state and cancel the timer that would
          // otherwise end the call.
          if (_remoteReconnectTimer != null) {
            _remoteReconnectTimer!.cancel();
            _remoteReconnectTimer = null;
            emit(
              state.copyWith(
                networkStatus: state.networkStatus.copyWith(
                  isRemoteReconnecting: false,
                ),
              ),
            );
          }

          // Both parties are in the Agora channel → call POST /activate (HTTP)
          // This records the activeAt timestamp on the server and starts billing.
          // Guarded by _hasActivated, so a rejoin after a network drop never
          // triggers a second /activate call.
          if (!_hasActivated && state.session != null) {
            _activateCallSession(state.session!.callId);
          }

          emit(
            state.copyWith(
              mediaStatus: CallMediaStatus.active,
              isRemoteUserJoined: true,
              remoteUid: remoteUid,
            ),
          );
          break;

        case AgoraRemoteUserLeft(:final reason):
          if (_hasTerminated) break;

          if (reason == UserOfflineReasonType.userOfflineQuit) {
            // The peer left the channel voluntarily — this is Agora's own
            // signal that they tapped "End Call", not a dropped connection,
            // so there's no reason to show a "reconnecting" banner or wait
            // the full network-blip grace period. Give the authoritative
            // server-pushed `ended` socket event (handled in
            // _handleCallTerminated) a short window to land first — it
            // carries the real final billing numbers — and only if it
            // doesn't arrive in time, finalize locally by fetching the
            // latest call details from the server so the summary screen
            // never shows stale duration/points.
            appLogger.d(
              '📴 [CallCubit] Remote participant left voluntarily. '
              'Waiting briefly for server confirmation.',
            );
            _remoteReconnectTimer?.cancel();
            _remoteReconnectTimer = Timer(const Duration(seconds: 4), () {
              if (isClosed || _hasTerminated) return;
              unawaited(_finalizeVoluntaryRemoteLeave());
            });
            break;
          }

          // Agora's onUserOffline can fire for reasons other than a genuine
          // hangup (e.g. a momentary media-track state change while the peer
          // mutes audio/video), so a non-voluntary reason here is not
          // treated as an instant, unconditional hangup. The actual,
          // authoritative "call ended" signal is the server-pushed socket
          // event handled in _handleCallTerminated — this branch only gives
          // the peer a grace window to prove they're actually still there
          // before we hang up locally.
          appLogger.d(
            '⚠️ [CallCubit] Remote participant reported offline '
            '(reason: $reason). Waiting up to 25s for rejoin.',
          );
          emit(
            state.copyWith(
              networkStatus: state.networkStatus.copyWith(
                isRemoteReconnecting: true,
              ),
            ),
          );
          _remoteReconnectTimer?.cancel();
          _remoteReconnectTimer = Timer(const Duration(seconds: 25), () {
            if (isClosed || _hasTerminated) return;
            _hasTerminated = true;
            appLogger.d(
              '🔴 [CallCubit] Remote did not rejoin in time. Ending call.',
            );
            _stopTimer();
            emit(
              state.copyWith(
                status: CallScreenStatus.ended,
                mediaStatus: CallMediaStatus.ended,
                isRemoteUserJoined: false,
                errorMessage:
                    "The call ended because the other participant's "
                    'connection was lost.',
                session: state.session?.copyWith(
                  endReason: 'remote_network_timeout',
                ),
                networkStatus: const CallNetworkStatus(),
              ),
            );
            _agoraService.leaveChannel();
            _cleanupResources();
          });
          break;

        case AgoraConnectionChanged(state: final connectionState):
          if (connectionState ==
              ConnectionStateType.connectionStateReconnecting) {
            emit(state.copyWith(mediaStatus: CallMediaStatus.reconnecting));

            // The one-shot leave+rejoin retry below only fires once Agora
            // escalates to `connectionStateFailed`, which it may never do
            // for some blips — this is the backstop so a mid-call drop
            // can't leave the screen stuck on "Reconnecting..." forever.
            if (state.status == CallScreenStatus.active) {
              _localMidCallReconnectTimer?.cancel();
              _localMidCallReconnectTimer = Timer(
                const Duration(seconds: 25),
                () {
                  if (isClosed || _hasTerminated) return;
                  if (state.mediaStatus != CallMediaStatus.reconnecting) {
                    return;
                  }
                  _hasTerminated = true;
                  appLogger.d(
                    '🔴 [CallCubit] Local connection did not recover in '
                    'time. Ending call.',
                  );
                  _stopTimer();
                  emit(
                    state.copyWith(
                      status: CallScreenStatus.ended,
                      mediaStatus: CallMediaStatus.failed,
                      errorMessage:
                          'The call ended because your connection was '
                          'unstable for too long.',
                      session: state.session?.copyWith(
                        endReason: 'local_network_timeout',
                      ),
                      networkStatus: const CallNetworkStatus(),
                    ),
                  );
                  _agoraService.leaveChannel();
                  _cleanupResources();
                },
              );
            }
          } else if (connectionState ==
              ConnectionStateType.connectionStateConnected) {
            _localMidCallReconnectTimer?.cancel();
            _localMidCallReconnectTimer = null;
            if (state.mediaStatus == CallMediaStatus.reconnecting) {
              emit(state.copyWith(mediaStatus: CallMediaStatus.active));
            }
          } else if (connectionState ==
              ConnectionStateType.connectionStateFailed) {
            if (!_hasRetriedConnectionFailure && state.session != null) {
              // Agora already spends ~10s trying to reconnect internally
              // before reporting `failed`, but a screen-off / brief network
              // drop can still land here. Give the call one real chance to
              // recover via a manual leave+rejoin before ending it — a call
              // should not drop just because of a transient hiccup.
              _hasRetriedConnectionFailure = true;
              appLogger.d(
                '⚠️ [CallCubit] Media connection failed — retrying join once.',
              );
              emit(state.copyWith(mediaStatus: CallMediaStatus.reconnecting));
              unawaited(_retryAgoraConnection(state.session!));
            } else {
              _localMidCallReconnectTimer?.cancel();
              _localMidCallReconnectTimer = null;
              emit(
                state.copyWith(
                  status: CallScreenStatus.failed,
                  mediaStatus: CallMediaStatus.failed,
                  isRemoteUserJoined: false,
                  errorMessage: 'Media connection failed.',
                ),
              );
              _cleanupResources();
            }
          }
          break;

        case AgoraNetworkQualityChanged(
          :final remoteUid,
          :final txQuality,
          :final rxQuality,
        ):
          final level = _worstQuality(txQuality, rxQuality);
          if (remoteUid == 0) {
            if (level != _lastEmittedLocalQuality) {
              _lastEmittedLocalQuality = level;
              emit(
                state.copyWith(
                  networkStatus: state.networkStatus.copyWith(
                    localQuality: level,
                  ),
                ),
              );
            }
          } else {
            if (level != _lastEmittedRemoteQuality) {
              _lastEmittedRemoteQuality = level;
              emit(
                state.copyWith(
                  networkStatus: state.networkStatus.copyWith(
                    remoteQuality: level,
                  ),
                ),
              );
            }
          }
          break;

        case AgoraTokenWillExpire():
          appLogger.d('⚠️ [CallCubit] Agora token will expire soon — refreshing.');
          unawaited(_refreshAgoraToken());
          break;

        case AgoraTokenExpired():
          appLogger.d('❌ [CallCubit] Agora token expired.');
          emit(
            state.copyWith(
              status: CallScreenStatus.failed,
              mediaStatus: CallMediaStatus.failed,
              isRemoteUserJoined: false,
              errorMessage: 'Calling session expired due to token expiry.',
            ),
          );
          _cleanupResources();
          break;

        case AgoraCallError(:final code, :final message):
          appLogger.d('❌ [CallCubit] Agora error callback: [$code] $message');
          break;
      }
    });
  }

  NetworkQualityLevel _qualityLevel(QualityType quality) {
    switch (quality) {
      case QualityType.qualityExcellent:
      case QualityType.qualityGood:
        return NetworkQualityLevel.good;
      case QualityType.qualityPoor:
      case QualityType.qualityBad:
        return NetworkQualityLevel.poor;
      case QualityType.qualityVbad:
      case QualityType.qualityDown:
        return NetworkQualityLevel.bad;
      default:
        return NetworkQualityLevel.unknown;
    }
  }

  /// Takes the worse of tx/rx quality; unknown readings are ignored in
  /// favor of a definite one so a single "unknown" tick right after "poor"
  /// doesn't flicker the indicator back to neutral.
  NetworkQualityLevel _worstQuality(QualityType tx, QualityType rx) {
    const severity = {
      NetworkQualityLevel.unknown: -1,
      NetworkQualityLevel.good: 0,
      NetworkQualityLevel.poor: 1,
      NetworkQualityLevel.bad: 2,
    };
    final txLevel = _qualityLevel(tx);
    final rxLevel = _qualityLevel(rx);
    return severity[txLevel]! >= severity[rxLevel]! ? txLevel : rxLevel;
  }

  /// Fast, local-device offline signal shown as a banner only — never
  /// drives call termination directly. All actual end-call decisions stay
  /// with Agora's own connection events above, which already debounce
  /// brief blips; this just shaves the perceived lag on the UI from
  /// Agora's ~10s internal detection down to ~1-2s.
  void _subscribeToConnectivity() {
    _connectivitySub?.cancel();
    _connectivitySub = _connectivityService.onStatusChanged.listen((
      isOnline,
    ) {
      if (isClosed) return;
      emit(
        state.copyWith(
          networkStatus: state.networkStatus.copyWith(
            isLocalDeviceOffline: !isOnline,
          ),
        ),
      );
    });
  }

  /// One-shot recovery attempt after Agora reports a failed connection:
  /// leave and rejoin the same channel/token rather than immediately ending
  /// the call. If this also fails, the next `connectionStateFailed` event
  /// (guarded by `_hasRetriedConnectionFailure`) will end the call for real.
  Future<void> _retryAgoraConnection(CallSessionEntity session) async {
    try {
      await _agoraService.leaveChannel();
    } catch (e) {
      appLogger.d('⚠️ [CallCubit] leaveChannel before retry failed: $e');
    }
    if (isClosed) return;
    _joinRequested = false;
    await _connectToAgora(session, forceTokenUpdate: true);
  }

  /// Fetches the latest call details (which may carry a freshly-issued RTC
  /// token) and hands it to Agora so a long-running call doesn't drop when
  /// its token nears expiry.
  Future<void> _refreshAgoraToken() async {
    final session = state.session;
    if (session == null) return;

    final result = await _callRepository.getCallDetails(session.callId);
    if (isClosed) return;

    result.fold(
      (failure) => appLogger.d(
        '❌ [CallCubit] Failed to refresh call details for token renewal: '
        '${failure.message}',
      ),
      (refreshed) async {
        final newToken = refreshed.agoraToken;
        if (newToken == null || newToken.isEmpty) return;
        try {
          await _agoraService.renewToken(newToken);
          if (!isClosed) {
            emit(
              state.copyWith(
                session: state.session?.copyWith(agoraToken: newToken),
              ),
            );
          }
        } catch (e) {
          appLogger.d('❌ [CallCubit] Failed to renew Agora token: $e');
        }
      },
    );
  }

  void _startJoinTimeout() {
    _joinTimeoutTimer?.cancel();
    _joinTimeoutTimer = Timer(const Duration(seconds: 20), () async {
      final currentMediaStatus = state.mediaStatus;
      // _startJoinTimeout() is also re-armed mid-call by
      // _retryAgoraConnection() (after a transient Agora connection
      // failure), so `mediaStatus` alone isn't a safe "never connected"
      // signal — a call that already connected once can briefly revisit
      // `joining`/`waitingForRemote` while reconnecting. `_hasActivated`
      // is set exactly once, the moment both parties are confirmed in the
      // channel, and never resets for this call — gate on it too so this
      // timeout can never fire (and end the call) on a call that already
      // connected.
      if (!_hasActivated &&
          (currentMediaStatus == CallMediaStatus.joining ||
              currentMediaStatus == CallMediaStatus.waitingForRemote)) {
        appLogger.d('⏳ [CallCubit] Connection timeout. Aborting channel join.');
        final session = state.session;
        emit(
          state.copyWith(
            status: CallScreenStatus.failed,
            mediaStatus: CallMediaStatus.failed,
            isRemoteUserJoined: false,
            errorMessage:
                'Unable to establish the media connection. Please try again.',
          ),
        );
        await _agoraService.leaveChannel();
        _cleanupResources();

        // This is a purely local Agora-layer timeout — unlike endCall(), it
        // never told the backend the call is over. Left as-is, the peer
        // (e.g. a host who never accepted) never receives a cancel/end event
        // and is stuck on their ringing screen indefinitely. Notify the
        // backend the same way endCall() would for this call's stage.
        if (session != null && !_serverEndedCall && !_hasTerminated) {
          _hasTerminated = true;
          if (_localRole == CallParticipantRole.caller) {
            await _cancelCallUseCase(session.callId);
          } else {
            await _endCallUseCase(session.callId);
          }
        }
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Phase 3: Activation — triggered when remote user joins Agora
  // ---------------------------------------------------------------------------

  /// Calls POST /calls/:callId/activate via HTTP.
  /// This is the ONLY correct trigger for billing — no *fallback* to a
  /// local timer to fabricate billing on our own. A failed *attempt* at
  /// this call is, however, retried with backoff (see
  /// [_maxActivateRetries]) rather than given up on after one try — Agora
  /// media runs on a completely separate pipeline from this REST call, so
  /// a single transient network blip right as both sides join the channel
  /// would otherwise let a call run and feel completely normal for its
  /// full length while the server never records an `activatedAt` for it,
  /// silently losing billing for the whole call.
  Future<void> _activateCallSession(String callId) async {
    if (_hasActivated || _isActivating || state.status == CallScreenStatus.active) {
      return;
    }
    _isActivating = true;

    appLogger.d(
      '⚡ [CallCubit] Calling HTTP activate for callId: $callId '
      '(attempt ${_activateRetryAttempts + 1})',
    );

    final result = await _activateCallUseCase(callId);
    _isActivating = false;
    if (isClosed || _hasTerminated) return;

    result.fold(
      (failure) {
        // The peer's own activate (or a server-pushed `active` socket
        // event) may have already caught this call up while this attempt
        // was in flight — don't schedule a now-redundant retry.
        if (_hasActivated || state.status == CallScreenStatus.active) {
          appLogger.d(
            'ℹ️ [CallCubit] Activate lost race (already active via '
            'peer/socket) — ignoring: ${failure.message}',
          );
          return;
        }

        appLogger.d('❌ [CallCubit] Activate failed: ${failure.message}');

        if (_activateRetryAttempts >= _maxActivateRetries) {
          appLogger.d(
            '❌ [CallCubit] Activate permanently failed after '
            '$_maxActivateRetries retries — billing will not start for '
            'this call unless the peer\'s own activation catches it up.',
          );
          return;
        }

        _activateRetryAttempts++;
        final delay = Duration(seconds: _activateRetryAttempts * 2);
        appLogger.d(
          '⏳ [CallCubit] Retrying activate in ${delay.inSeconds}s '
          '(attempt $_activateRetryAttempts/$_maxActivateRetries)',
        );
        _activateRetryTimer?.cancel();
        _activateRetryTimer = Timer(delay, () {
          if (isClosed || _hasTerminated || _hasActivated) return;
          unawaited(_activateCallSession(callId));
        });
      },
      (session) {
        appLogger.d('✅ [CallCubit] Activate succeeded');
        _hasActivated = true;
        _activateRetryTimer?.cancel();
        _activateRetryTimer = null;
        // The /activate endpoint is a lightweight billing ack — it may omit
        // connection-identity fields (callType, agoraChannel, agoraToken,
        // hostId, callerId) that were already correctly set in state at
        // initiate/accept time. Blindly replacing the session with this
        // response would null those out right as the remote video view
        // renders (this handler runs from the AgoraRemoteUserJoined event),
        // crashing AgoraVideoView / flipping video calls to the audio UI.
        // Only the fields /activate is actually meant to update are merged
        // in; identity/connection fields are preserved from existing state.
        final current = state.session;
        final activated = current == null
            ? session
            : current.copyWith(
                status: session.status,
                duration: session.duration,
                billedMinutes: session.billedMinutes,
                totalPointsDebited: session.totalPointsDebited,
                ratePerMinute: session.ratePerMinute,
                endReason: session.endReason,
                agoraChannel: session.agoraChannel?.isNotEmpty == true
                    ? session.agoraChannel
                    : current.agoraChannel,
                agoraToken: session.agoraToken?.isNotEmpty == true
                    ? session.agoraToken
                    : current.agoraToken,
              );
        emit(state.copyWith(status: CallScreenStatus.active, session: activated));
        _startTimer();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Socket Events (Server → Client notifications only)
  // ---------------------------------------------------------------------------

  void _listenToSocketEvents() {
    _socketEventSub = _callRepository.callSocketEvents.listen((event) {
      if (isClosed) return;

      // `callSocketEvents` is one shared, app-wide stream — it is NOT scoped
      // to this particular call. A stray event for a different call (a
      // previous call's delayed/duplicate push, a reconnect replay, or
      // cross-talk from a quick succeeding call) would otherwise be treated
      // as belonging to this one and could terminate an active call within
      // seconds of it starting. Only react to events for the call this
      // cubit is actually running.
      final currentCallId = state.session?.callId;
      if (currentCallId != null &&
          currentCallId.isNotEmpty &&
          event.callId.isNotEmpty &&
          event.callId != currentCallId) {
        appLogger.d(
          '⚠️ [CallCubit] Ignoring socket event for unrelated call '
          '(event.callId=${event.callId}, current=$currentCallId)',
        );
        return;
      }

      appLogger.d(
        '📲 [CallCubit] Socket event: status=${event.status}, '
        'endReason=${event.endReason}, duration=${event.duration}, '
        'billedMinutes=${event.billedMinutes}',
      );

      switch (event.status) {
        case 'accepted':
          // Server notified caller that host accepted → update session with
          // host's Agora token if provided, then join channel
          if (state.status == CallScreenStatus.ringing ||
              state.status == CallScreenStatus.initiating) {
            final updatedSession = _mergeSocketEvent(event);
            emit(
              state.copyWith(
                status: CallScreenStatus.connecting,
                session: updatedSession,
              ),
            );
            if (updatedSession.agoraChannel?.isNotEmpty == true) {
              _connectToAgora(updatedSession);
            }
          }

        case 'active':
          // Server confirmed ACTIVE (billing started) — sync timer if not already
          if (state.status != CallScreenStatus.active) {
            _hasActivated = true;
            final updatedSession = _mergeSocketEvent(event);
            emit(
              state.copyWith(
                status: CallScreenStatus.active,
                session: updatedSession,
              ),
            );
            _startTimer();
          }

        case 'ended':
        case 'rejected':
        case 'missed':
        case 'cancelled':
          _handleCallTerminated(event);

        case 'insufficient_balance':
          _handleInsufficientBalance(event);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Phase 4: Ending the Call
  // ---------------------------------------------------------------------------

  Future<void> endCall() async {
    if (state.isCallEnded || _hasTerminated) return;
    _hasTerminated = true;

    final session = state.session;
    final currentStatus = state.status;

    // If Agora already reported the remote participant offline and we're
    // sitting in the grace window waiting for the authoritative `ended`
    // socket push (see the AgoraRemoteUserLeft handling above — this timer
    // is exactly what drives the "reconnecting" banner), the peer has
    // almost certainly already ended the call server-side; that's *why*
    // Agora saw them leave. Firing a fresh HTTP /end here would race an
    // end the server already recorded and can make it compute a bogus
    // near-zero duration for this second, redundant call. So a manual end
    // tap in that window asks the server what it already knows first,
    // instead of blindly re-triggering /end.
    final awaitingRemoteConfirmation = _remoteReconnectTimer != null;
    _remoteReconnectTimer?.cancel();
    _remoteReconnectTimer = null;

    // The billing/duration numbers shown in the post-call summary come from
    // this same call's server response (or the socket event, for the peer).
    // Emitting `ended` before this HTTP call resolves let the summary
    // dialog's own fetch race the server's billing finalization — the
    // dialog would ask for final numbers before the server had finished
    // computing them. So the finalized numbers are folded in *before* the
    // `ended` status is emitted, not after.
    //
    // The /end and /cancel responses only carry the billing fields, not the
    // call's identity fields (callId, hostId, callerId, agoraChannel/token,
    // callType come back empty) — merge just the billing fields onto the
    // existing session instead of replacing it outright, otherwise the
    // summary dialog fetches call details using an empty callId and 404s.
    var finalSession = session;

    // If the server already ended the call (socket event), skip the HTTP call
    // to avoid a redundant POST /end after the peer already triggered it.
    if (!_serverEndedCall && session != null) {
      if (awaitingRemoteConfirmation) {
        final detailsResult = await _callRepository.getCallDetails(session.callId);
        final alreadyEnded = detailsResult.fold(
          (_) => false,
          (s) => s.status.toLowerCase() == 'ended',
        );
        if (alreadyEnded) {
          detailsResult.fold(
            (_) {},
            (updated) => finalSession = _mergeBillingFields(session, updated),
          );
        } else {
          // Agora's offline report was a real network blip, not a hangup —
          // the server still thinks the call is active, so actually end it.
          final result = await _endCallUseCase(session.callId);
          result.fold((_) {}, (updated) => finalSession = _mergeBillingFields(session, updated));
        }
      } else if (currentStatus == CallScreenStatus.ringing ||
          currentStatus == CallScreenStatus.initiating) {
        // User cancelled before host answered — HTTP cancel
        final result = await _cancelCallUseCase(session.callId);
        result.fold((_) {}, (updated) => finalSession = _mergeBillingFields(session, updated));
      } else if (currentStatus == CallScreenStatus.active ||
          currentStatus == CallScreenStatus.connecting) {
        // Active call ended locally — HTTP end triggers billing + push to peer
        final result = await _endCallUseCase(session.callId);
        result.fold((_) {}, (updated) => finalSession = _mergeBillingFields(session, updated));
      }
    }

    if (isClosed) return;

    emit(
      state.copyWith(
        status: CallScreenStatus.ended,
        isRemoteUserJoined: false,
        session: finalSession,
        // Clears a stale `isRemoteReconnecting`/quality banner left over
        // from right before this end — otherwise the status label keeps
        // showing "reconnecting" forever even though the call has ended,
        // since that check runs ahead of the ended-status check.
        networkStatus: const CallNetworkStatus(),
      ),
    );

    _cleanupResources();
  }

  /// Merges only the billing/duration fields from an /end or /cancel
  /// response onto the existing session, preserving identity fields
  /// (callId, hostId, callerId, callType, agoraChannel/token) that those
  /// endpoints don't echo back.
  CallSessionEntity _mergeBillingFields(
    CallSessionEntity current,
    CallSessionEntity response,
  ) {
    return current.copyWith(
      status: response.status,
      duration: response.duration,
      billedMinutes: response.billedMinutes,
      totalPointsDebited: response.totalPointsDebited,
      ratePerMinute: response.ratePerMinute == 0
          ? current.ratePerMinute
          : response.ratePerMinute,
      endReason: response.endReason.isNotEmpty
          ? response.endReason
          : current.endReason,
    );
  }

  // ---------------------------------------------------------------------------
  // Minimize / Restore — pure UI-state flips. The call itself (Agora
  // session, timers, socket subscriptions) keeps running underneath
  // regardless of whether the full CallScreen or the floating bubble is
  // what's currently mounted, so neither of these touches _cleanupResources
  // or any live connection.
  // ---------------------------------------------------------------------------

  void minimizeCall() {
    if (state.isCallEnded) return;
    emit(state.copyWith(isMinimized: true));
  }

  void restoreCall() {
    if (!state.isMinimized) return;
    emit(state.copyWith(isMinimized: false));
  }

  // ---------------------------------------------------------------------------
  // Media Controls
  // ---------------------------------------------------------------------------

  void toggleMuteAudio() {
    emit(state.copyWith(isMuted: _mediaControls.toggleMuteAudio(state.isMuted)));
  }

  void toggleMuteVideo() {
    emit(
      state.copyWith(
        isVideoMuted: _mediaControls.toggleMuteVideo(state.isVideoMuted),
      ),
    );
  }

  void toggleSpeakerphone() {
    emit(
      state.copyWith(
        isSpeakerOn: _mediaControls.toggleSpeakerphone(state.isSpeakerOn),
      ),
    );
  }

  void switchCamera() {
    _mediaControls.switchCamera();
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Finalizes the call after the remote participant voluntarily left the
  /// Agora channel (a genuine hang-up) but the authoritative server-pushed
  /// `ended` socket event didn't land within the short grace window. Fetches
  /// the latest call details via HTTP so the final duration/billed
  /// minutes/points reflect what the server actually recorded, instead of
  /// guessing from whatever was last synced locally.
  Future<void> _finalizeVoluntaryRemoteLeave() async {
    if (_hasTerminated) return;
    _hasTerminated = true;

    _stopTimer();

    final session = state.session;
    var finalSession = session;
    if (session != null) {
      final result = await _callRepository.getCallDetails(session.callId);
      if (isClosed) return;
      result.fold(
        (failure) => appLogger.d(
          '❌ [CallCubit] Failed to fetch final call details after remote '
          'hang-up: ${failure.message}',
        ),
        (updated) => finalSession = _mergeBillingFields(session, updated),
      );
    }

    if (isClosed) return;

    appLogger.d('🔴 [CallCubit] Remote left voluntarily. Ending call.');
    emit(
      state.copyWith(
        status: CallScreenStatus.ended,
        mediaStatus: CallMediaStatus.ended,
        isRemoteUserJoined: false,
        session: finalSession,
        networkStatus: const CallNetworkStatus(),
      ),
    );
    _agoraService.leaveChannel();
    _cleanupResources();
  }

  void _handleCallTerminated(CallSocketEvent event) {
    if (_hasTerminated) return;
    _hasTerminated = true;
    _serverEndedCall = true;

    // Cancel any pending "waiting for remote to rejoin/confirm" timer —
    // this authoritative event just answered that question, so the local
    // fallback (which would otherwise fire later and, on the 25s branch,
    // leave `isRemoteReconnecting` stuck true forever) must not run.
    _remoteReconnectTimer?.cancel();
    _remoteReconnectTimer = null;

    _stopTimer();
    emit(
      state.copyWith(
        status: CallScreenStatus.ended,
        isRemoteUserJoined: false,
        session: _mergeSocketEvent(event),
        // See endCall() — clears a stale reconnecting banner so the label
        // reflects the call actually being over.
        networkStatus: const CallNetworkStatus(),
      ),
    );
    _agoraService.leaveChannel();
    _cleanupResources();
  }

  void _handleInsufficientBalance(CallSocketEvent event) {
    if (_hasTerminated) return;
    _hasTerminated = true;
    _serverEndedCall = true;

    _remoteReconnectTimer?.cancel();
    _remoteReconnectTimer = null;

    _stopTimer();
    emit(
      state.copyWith(
        status: CallScreenStatus.insufficientBalance,
        isRemoteUserJoined: false,
        session: _mergeSocketEvent(event),
        errorMessage: 'Call ended: insufficient balance',
        networkStatus: const CallNetworkStatus(),
      ),
    );
    _agoraService.leaveChannel();
    _cleanupResources();
  }

  CallSessionEntity _mergeSocketEvent(CallSocketEvent event) {
    final current = state.session;
    if (current == null) {
      return CallSessionEntity(
        callId: event.callId,
        status: event.status,
        callType: event.callType ?? CallType.audio,
        duration: event.duration ?? 0,
        billedMinutes: event.billedMinutes ?? 0,
        totalPointsDebited: event.totalPointsDebited ?? 0,
        ratePerMinute: 0,
        endReason: event.endReason ?? '',
        hostId: event.hostId ?? '',
        callerId: event.callerId ?? '',
        agoraChannel: event.agoraChannel,
        agoraToken: event.agoraToken,
      );
    }
    return current.copyWith(
      callId: event.callId.isNotEmpty ? event.callId : null,
      callerId: (event.callerId?.isNotEmpty == true) ? event.callerId : null,
      hostId: (event.hostId?.isNotEmpty == true) ? event.hostId : null,
      agoraChannel: event.agoraChannel ?? current.agoraChannel,
      agoraToken: event.agoraToken ?? current.agoraToken,
      status: event.status,
      callType: event.callType ?? current.callType,
      duration: event.duration ?? current.duration,
      billedMinutes: event.billedMinutes ?? current.billedMinutes,
      totalPointsDebited:
          event.totalPointsDebited ?? current.totalPointsDebited,
      endReason: event.endReason ?? current.endReason,
    );
  }

  void _startTimer() {
    _durationTicker.start(() {
      if (isClosed) return;
      emit(state.copyWith(durationSeconds: state.durationSeconds + 1));
    });
    // Controls only auto-hide for video calls, once the call is active —
    // start the 3s countdown the moment we enter that state.
    if (state.session?.callType.isVideo ?? false) {
      _scheduleControlsAutoHide();
    }
  }

  void _stopTimer() {
    _durationTicker.stop();
  }

  /// Ephemeral UI-only state: whether the in-call control buttons are
  /// visible. Auto-hides 3s after a video call becomes active, and
  /// reappears on tap.
  void showControls() {
    if (!state.controlsVisible) {
      emit(state.copyWith(controlsVisible: true));
    }
    _scheduleControlsAutoHide();
  }

  void _scheduleControlsAutoHide() {
    _controlsAutoHideTimer?.cancel();
    _controlsAutoHideTimer = Timer(const Duration(seconds: 3), () {
      if (isClosed) return;
      emit(state.copyWith(controlsVisible: false));
    });
  }

  void _cleanupResources() {
    // A host's "on call" / "busy" presence flag is set and cleared entirely
    // server-side and only reaches any given device via that device's own
    // presence socket's host_status_update push — if that specific push is
    // delayed or dropped right as the call ends, whichever device is
    // watching (the host's own dashboard, or the caller's host list showing
    // the host they just talked to) is left stuck on stale "on call" data,
    // since nothing else would ever ask the server again. This fires for
    // BOTH roles: requesting a snapshot only refreshes the requesting
    // device's own socket connection, so a caller checking whether the host
    // they just hung up on is free again needs this exact same nudge on
    // their own device — the host requesting it themselves does nothing for
    // the caller's view, and vice versa.
    if (_localRole != null) {
      _syncPresenceAfterCallEnd();
    }

    _stopTimer();
    _joinTimeoutTimer?.cancel();
    _joinTimeoutTimer = null;
    _remoteReconnectTimer?.cancel();
    _remoteReconnectTimer = null;
    _localMidCallReconnectTimer?.cancel();
    _localMidCallReconnectTimer = null;
    _activateRetryTimer?.cancel();
    _activateRetryTimer = null;
    _agoraEventSub?.cancel();
    _agoraEventSub = null;
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _localRole = null;
    _joinRequested = false;

    if (state.session != null) {
      _callRepository.unsubscribeCallSocket(state.session!.callId);
    }
    _socketEventSub?.cancel();
    _socketEventSub = null;
    _agoraService.dispose();
    unawaited(WakelockPlus.disable());
  }

  /// Requests a fresh presence snapshot as a manual recovery path — the
  /// same "don't just trust the live push" idiom already used for
  /// pull-to-refresh in HostDashCubit.refreshDashboardData() — the moment
  /// this device's own call ends, for whichever role this device played.
  ///
  /// Fired more than once on a short delay because the backend clearing
  /// the host's "busy" flag can itself lag a beat behind the /end response
  /// that just resolved; a single immediate request can land before that
  /// flip happens and simply echo back the same stale "still on call"
  /// snapshot. None of this blocks or delays the already-emitted `ended`
  /// state — it's a fire-and-forget nudge to an external service, not part
  /// of the call's own lifecycle.
  void _syncPresenceAfterCallEnd() {
    _presenceSocketService.requestPresenceSnapshot();
    for (final delay in const [Duration(seconds: 2), Duration(seconds: 5)]) {
      Future.delayed(delay, () {
        if (isClosed) return;
        _presenceSocketService.requestPresenceSnapshot();
      });
    }
  }

  @override
  Future<void> close() {
    _cleanupResources();
    return super.close();
  }
}
