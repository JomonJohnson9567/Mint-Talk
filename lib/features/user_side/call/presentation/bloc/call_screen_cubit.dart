import 'dart:async';
import 'dart:math' as math;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:mint_talk/config/agora/agora_config.dart';
import 'package:mint_talk/config/env/env_config.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/services/agora/call_audio_route.dart';
import 'package:mint_talk/core/services/agora/i_agora_service.dart';
import 'package:mint_talk/core/services/audio/ringback_tone_service.dart';
import 'package:mint_talk/core/services/call_background/i_call_background_service.dart';
import 'package:mint_talk/core/services/connectivity/connectivity_service.dart';
import 'package:mint_talk/core/services/device_audio/device_audio_models.dart';
import 'package:mint_talk/core/services/device_audio/i_device_audio_service.dart';
import 'package:mint_talk/core/services/permissions/call_permission_service.dart';
import 'package:mint_talk/core/services/proximity/i_proximity_service.dart';
import 'package:mint_talk/core/services/session/session_manager.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/core/utils/server_clock.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_presence_entity.dart';
import '../../data/models/incoming_call_payload_dto.dart';
import '../../domain/entities/call_participant_role.dart';
import '../../domain/entities/call_session_entity.dart';
import '../../domain/entities/call_socket_event.dart';
import '../../domain/entities/call_token_entity.dart';
import '../../domain/entities/call_type.dart';
import '../../domain/repositories/i_call_repository.dart';
import '../../domain/usecases/accept_call_usecase.dart';
import '../../domain/usecases/activate_call_usecase.dart';
import '../../domain/usecases/cancel_call_usecase.dart';
import '../../domain/usecases/end_call_usecase.dart';
import '../../domain/usecases/get_call_token_usecase.dart';
import '../../domain/usecases/initiate_call_usecase.dart';
import 'call_background_sync.dart';
import 'call_device_audio_watcher.dart';
import 'call_duration_ticker.dart';
import 'call_media_controls.dart';
import 'call_media_readiness.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/ring_window.dart';

part 'call_screen_state.dart';

/// Manages the full call lifecycle state for both caller (user) and host.
///
/// Flow (Caller):
///   startOutgoingCall() → HTTP initiateCall → ringing
///   ← socket call_accepted → connecting → HTTP /token → join Agora (uid 1)
///
/// Flow (Host):
///   acceptIncomingCall(payload) → connecting → HTTP acceptCall → join Agora (uid 2)
///   (startIncomingCall(session) when the accept already happened elsewhere)
///
/// Both roles, once joined + local audio published ([CallMediaReadiness]):
///   → HTTP /activate (once) → `accepted` (waiting for the peer, no billing)
///                           → `active`   (billing started)
///   ← socket call_active → active; the duration counts from the server's
///     `activeAt`, not from acceptance
///   endCall() → HTTP /end → ended (explicit user hang-up only)
///
/// An unanswered call is cancelled by the caller after [noAnswerTimeout]
/// (20s) and shown as "No answer"; the host's overlay closes on the same
/// limit.
///
/// The backend owns the connection timeout (60s after acceptance → status
/// `failed`, endReason `connection_timeout`) and balance exhaustion
/// (`call_insufficient_balance`). Server-driven ends only clean up locally
/// — they never send /end. /end is sent for an explicit hang-up or a
/// genuine local failure (permission denied, Agora join/media failure,
/// unrecoverable token or connection loss).
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
  final IConnectivityService _connectivityService;
  final IPresenceSocketService _presenceSocketService;
  final GetCallTokenUseCase _getCallTokenUseCase;
  final IRingbackToneService _ringbackTone;
  final IDeviceAudioService _deviceAudioService;
  final ServerClock _serverClock;
  final IProximityService _proximity;
  final ICallBackgroundService _callBackground;

  late final CallMediaControls _mediaControls = CallMediaControls(
    _agoraService,
  );
  late final CallDeviceAudioWatcher _deviceAudioWatcher =
      CallDeviceAudioWatcher(_deviceAudioService);
  late final CallBackgroundSync _backgroundSync = CallBackgroundSync(
    _callBackground,
  );
  final CallDurationTicker _durationTicker = CallDurationTicker();
  final CallMediaReadiness _readiness = CallMediaReadiness();

  /// Armed at acceptance as a backstop for a lost `connection_timeout`
  /// push: fires a little after the server's own timeout and reconciles
  /// with the server. It never sends /end — the server owns this timeout.
  Timer? _connectionTimeoutTimer;
  static const int _defaultServerConnectionTimeoutSeconds = 60;
  @visibleForTesting
  static Duration connectionTimeoutBackstopMargin = const Duration(seconds: 15);

  /// After the peer leaves Agora voluntarily we rely on *their* /end; this
  /// long after, the call is re-read and ended from this side if the server
  /// still thinks it's running (their /end was lost).
  @visibleForTesting
  static Duration peerQuitVerifyDelay = const Duration(seconds: 3);

  /// Caller-side ring limit: a call the host hasn't answered by the server's
  /// `ringExpiresAt` is shown as "No answer". [noAnswerTimeout] is only the
  /// fallback when /initiate sent no `ringExpiresAt`. The host's incoming
  /// overlay closes on the same deadline — see `IncomingCallSessionCubit`.
  Timer? _noAnswerTimer;
  @visibleForTesting
  static Duration noAnswerTimeout = RingWindow.fallback;

  /// With a server deadline, the server ends the call itself and pushes
  /// `call_missed`; this much slack lets that push land first (so the call
  /// is recorded as missed) before /cancel is sent as a backstop.
  @visibleForTesting
  static Duration ringExpiryGrace = const Duration(seconds: 2);

  Timer? _tokenRenewTimer;
  bool _isRenewingToken = false;
  bool _isFetchingToken = false;
  bool _hasRecoveredExpiredToken = false;

  Timer? _remoteReconnectTimer;
  Timer? _localMidCallReconnectTimer;
  Timer? _controlsAutoHideTimer;
  StreamSubscription<CallSocketEvent>? _socketEventSub;
  StreamSubscription<AgoraCallEvent>? _agoraEventSub;
  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<bool>? _socketConnectionSub;

  /// Watches the call's host presence while active — see
  /// [_watchHostReleaseWhileActive].
  StreamSubscription<HostPresenceEntity>? _hostPresenceSub;
  bool _hostReleaseReconcileInFlight = false;

  /// Keeps [CallScreenState.dialledHost] in sync with that host's presence —
  /// see [_watchDialledHostPresence]. Deliberately outside
  /// [_cleanupResources], which runs when the call ends.
  StreamSubscription<HostPresenceEntity>? _dialledHostPresenceSub;

  NetworkQualityLevel _lastEmittedLocalQuality = NetworkQualityLevel.unknown;
  NetworkQualityLevel _lastEmittedRemoteQuality = NetworkQualityLevel.unknown;

  CallParticipantRole? _localRole;

  /// The Agora uid this device joined with, so remote events can be told
  /// apart from our own.
  int? _localUid;
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

  /// Set when the first /activate goes out. Media events only ever trigger
  /// that first attempt; later ones come from the retry backoff or a
  /// server reconcile, so a duplicate Agora callback can't skip the backoff.
  bool _hasRequestedActivation = false;

  /// Number of retry attempts made after a failed activate call.
  int _activateRetryAttempts = 0;
  static const int _maxActivateRetries = 4;
  Timer? _activateRetryTimer;

  /// True once this device's /activate returned `accepted`. /activate is
  /// not re-sent after that; [_activationPollTimer] re-reads the call
  /// instead, in case the `call_active` push is lost.
  bool _hasAcknowledgedMedia = false;
  Timer? _activationPollTimer;
  static const Duration _activationPollInterval = Duration(seconds: 5);

  /// Server time billing started; the duration display counts from it.
  /// [_activeAtFromServer] is false while it's only a local fallback, so a
  /// later event carrying the real `activeAt` can still correct it.
  DateTime? _activeAt;
  bool _activeAtFromServer = false;

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

  /// Bumped at the start of every call attempt. An initiate/accept response
  /// that resolves after the user ended the call — or after "Call again"
  /// started a newer attempt — carries a stale generation and must not
  /// resurrect the screen; it only gets a compensating cancel/end.
  int _callGeneration = 0;

  /// True when the initiate/accept response for [generation] arrived too
  /// late: the attempt was superseded or already ended locally.
  bool _isStaleAttempt(int generation) =>
      isClosed || generation != _callGeneration || _hasTerminated;

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
    this._connectivityService,
    this._presenceSocketService,
    this._getCallTokenUseCase,
    this._ringbackTone,
    this._deviceAudioService,
    SessionManager sessionManager,
    this._serverClock,
    this._proximity,
    this._callBackground,
  ) : super(const CallScreenState()) {
    _forcedLogoutSub = sessionManager.forcedLogouts.listen(
      (_) => _abortForForcedLogout(),
    );
    _backgroundActionSub = _callBackground.actions.listen(_onBackgroundAction);
  }

  StreamSubscription<void>? _forcedLogoutSub;
  StreamSubscription<CallBackgroundAction>? _backgroundActionSub;

  @override
  void onChange(Change<CallScreenState> change) {
    super.onChange(change);
    _syncRingbackTone(change.nextState);
    _syncProximitySensor(change.nextState);
    _backgroundSync.sync(change.nextState);
  }

  /// Taps on the ongoing-call notification / picture-in-picture actions.
  /// `openCall` is navigation, handled by the UI (see `app.dart`).
  void _onBackgroundAction(CallBackgroundAction action) {
    if (state.status == CallScreenStatus.initial || state.isCallEnded) return;
    switch (action) {
      case CallBackgroundAction.hangUp:
        unawaited(endCall());
      case CallBackgroundAction.toggleMute:
        toggleMuteAudio();
      case CallBackgroundAction.toggleCamera:
        final isVideo = (state.session?.callType ?? state.callType)?.isVideo;
        if (isVideo == true) toggleMuteVideo();
      case CallBackgroundAction.openCall:
        break;
    }
  }

  /// Screen blanks at the ear only for an audio call on the earpiece.
  /// Speaker, Bluetooth, wired headset, video and every ended state turn it
  /// off. A host's incoming ring stays off so Accept can still be tapped.
  void _syncProximitySensor(CallScreenState s) {
    final callType = s.session?.callType ?? s.callType;
    final isInCall = s.status != CallScreenStatus.initial && !s.isCallEnded;
    final isHostRinging = s.isHost && s.status == CallScreenStatus.ringing;
    final enabled =
        callType != null &&
        !callType.isVideo &&
        isInCall &&
        !isHostRinging &&
        s.audio.route == CallAudioRoute.earpiece;
    unawaited(_proximity.setEnabled(enabled));
  }

  /// Caller-only waiting tone from ringing until media is live; every other
  /// status (active, ended, failed, insufficientBalance, initial) silences it.
  void _syncRingbackTone(CallScreenState s) {
    final isWaiting =
        !s.isHost &&
        (s.status == CallScreenStatus.ringing ||
            s.status == CallScreenStatus.connecting);
    unawaited(isWaiting ? _ringbackTone.start() : _ringbackTone.stop());
  }

  /// The session was ended from outside (login on another device, refresh
  /// rejected) while a call may be running. Drops media and every timer and
  /// returns to idle — straight to `initial`, not `ended`, so no summary
  /// dialog or wallet refresh fires with credentials that are already gone.
  /// No /end is sent: it would be rejected with the revoked token.
  void _abortForForcedLogout() {
    _stopWatchingDialledHost();
    if (isClosed || state.status == CallScreenStatus.initial) return;
    appLogger.w('[CallCubit] Forced logout — tearing down the current call');
    _hasTerminated = true;
    _cleanupResources();
    emit(const CallScreenState());
  }

  /// Exposes the live Agora engine for widgets that need to attach a video
  /// view (e.g. [AgoraVideoView]) — the cubit already owns [IAgoraService],
  /// so this avoids the UI resolving it from the service locator directly.
  RtcEngine? get agoraEngine => _agoraService.engine;

  /// Resets every per-call guard before a new call starts on this cubit.
  void _resetCallFlags(CallParticipantRole role) {
    _localRole = role;
    _localUid = null;
    _hasTerminated = false;
    _serverEndedCall = false;
    _hasActivated = false;
    _isActivating = false;
    _hasRequestedActivation = false;
    _activateRetryAttempts = 0;
    _activateRetryTimer?.cancel();
    _activateRetryTimer = null;
    _hasAcknowledgedMedia = false;
    _activationPollTimer?.cancel();
    _activationPollTimer = null;
    _activeAt = null;
    _activeAtFromServer = false;
    _joinRequested = false;
    _hasRetriedConnectionFailure = false;
    _isRenewingToken = false;
    _isFetchingToken = false;
    _hasRecoveredExpiredToken = false;
    _readiness.reset();
    _lastEmittedLocalQuality = NetworkQualityLevel.unknown;
    _lastEmittedRemoteQuality = NetworkQualityLevel.unknown;
  }

  // ---------------------------------------------------------------------------
  // Phase 1: Call Initiation (Caller side)
  // ---------------------------------------------------------------------------

  /// Initiates an outgoing call via HTTP REST only.
  /// The backend validates, saves the call as RINGING, and pushes
  /// incoming_call to the host over WebSocket. The caller does NOT join
  /// Agora yet — it joins with the initiate response's credentials (token,
  /// agoraChannel, agoraUid) once the host accepts.
  Future<void> startOutgoingCall({
    required String hostId,
    required CallType callType,
    String displayName = '',
    String? avatarUrl,
    bool isHostFavorite = false,
    HostEntity? host,
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
        hostId: hostId,
        callType: callType,
        isHostFavorite: isHostFavorite,
        dialledHost: host,
      ),
    );
    _watchDialledHostPresence(hostId);

    _resetCallFlags(CallParticipantRole.caller);
    final generation = ++_callGeneration;

    final result = await _initiateCallUseCase(
      InitiateCallParams(hostId: hostId, callType: callType),
    );

    if (_isStaleAttempt(generation)) {
      // Ended (or replaced) while /initiate was in flight: endCall had no
      // callId to cancel then, so cancel the server call now and leave the
      // already-ended state alone — emitting `ringing` here is what used to
      // strand the screen with an end button that ignored every tap.
      result.fold((_) {}, (session) {
        appLogger.d(
          '[CallCubit] /initiate returned after the call was ended — '
          'cancelling ${session.callId} on the server.',
        );
        unawaited(_endCallWithRetry(() => _cancelCallUseCase(session.callId)));
      });
      return;
    }

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: CallScreenStatus.failed,
            mediaStatus: CallMediaStatus.failed,
            errorMessage: failure.message,
            requiresRecharge: _isInsufficientBalanceFailure(failure),
          ),
        );
      },
      (session) {
        final effectiveSession = session.callType != callType
            ? session.copyWith(callType: callType)
            : session;

        emit(
          state.copyWith(
            status: CallScreenStatus.ringing,
            session: effectiveSession,
          ),
        );
        // Subscribe to server-pushed socket events for this call
        _callRepository.subscribeCallSocket(effectiveSession.callId);
        _listenToSocketEvents();
        _subscribeToSocketConnection();
        _startNoAnswerTimer();
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
    _stopWatchingDialledHost();
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

    _resetCallFlags(CallParticipantRole.host);
    final generation = ++_callGeneration;

    final result = await _acceptCallUseCase(payload.callId);
    if (_isStaleAttempt(generation)) {
      // Ended while /accept was in flight — the server now holds an
      // accepted call this device has already left, so close it there.
      if (result.isRight()) {
        unawaited(_endStaleServerCall(payload.callId));
      }
      return;
    }

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
        // /accept returns only the channel/token, so the participant ids
        // come from the incoming-call payload — hostId is what the
        // host-release watch keys on (see _watchHostReleaseWhileActive).
        final effectiveSession = session.copyWith(
          callType: payload.callType,
          hostId: session.hostId.isNotEmpty ? null : payload.hostId,
          callerId: session.callerId.isNotEmpty ? null : payload.callerId,
        );

        emit(state.copyWith(session: effectiveSession));
        _startAcceptedCallOnHost(effectiveSession);
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
    _stopWatchingDialledHost();
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

    _resetCallFlags(CallParticipantRole.host);
    ++_callGeneration;
    _startAcceptedCallOnHost(session);
  }

  /// Shared host-side continuation once the call is accepted: listen for
  /// server events, start the connection timeout, then join Agora with the
  /// accept response's token (or fetch one if it didn't carry it).
  void _startAcceptedCallOnHost(CallSessionEntity session) {
    _callRepository.subscribeCallSocket(session.callId);
    _listenToSocketEvents();
    _subscribeToSocketConnection();
    _startConnectionTimeout();

    final hasCredentials =
        session.agoraChannel?.isNotEmpty == true &&
        session.agoraToken?.isNotEmpty == true;
    if (hasCredentials) {
      _scheduleTokenRenewal(session.tokenExpiresInSeconds);
      _connectToAgora(session);
    } else {
      unawaited(_fetchTokenAndConnect());
    }
  }

  // ---------------------------------------------------------------------------
  // Agora token (POST /calls/:callId/token)
  // ---------------------------------------------------------------------------

  /// Fallback for when the initiate/accept response carried no RTC
  /// credentials: fetches this participant's token via /token and joins.
  /// Retried briefly — it sits inside the connection-timeout window, and a
  /// single transient failure shouldn't drop a call that just connected.
  Future<void> _fetchTokenAndConnect() async {
    final callId = state.session?.callId;
    if (callId == null ||
        _isFetchingToken ||
        _joinRequested ||
        _hasTerminated) {
      return;
    }
    _isFetchingToken = true;

    const maxAttempts = 3;
    CallTokenEntity? token;
    String lastError = '';
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final result = await _getCallTokenUseCase(callId);
      if (isClosed || _hasTerminated) {
        _isFetchingToken = false;
        return;
      }
      token = result.fold((failure) {
        lastError = failure.message;
        return null;
      }, (t) => t);
      if (token != null) break;
      appLogger.d(
        '⚠️ [CallCubit] Token fetch attempt $attempt/$maxAttempts failed: '
        '$lastError',
      );
      if (attempt < maxAttempts) {
        await Future.delayed(const Duration(seconds: 2));
        if (isClosed || _hasTerminated) {
          _isFetchingToken = false;
          return;
        }
      }
    }
    _isFetchingToken = false;

    if (token == null) {
      _failAndEndCall('Unable to connect the call. You were not charged.');
      return;
    }

    final updated = _applyToken(state.session!, token);
    emit(state.copyWith(session: updated));
    _scheduleTokenRenewal(token.expiresInSeconds);
    _connectToAgora(updated);
  }

  CallSessionEntity _applyToken(
    CallSessionEntity session,
    CallTokenEntity token,
  ) {
    return session.copyWith(
      agoraToken: token.token,
      agoraChannel: token.channelName?.isNotEmpty == true
          ? token.channelName
          : null,
      agoraUid: token.uid,
      tokenExpiresInSeconds: token.expiresInSeconds,
    );
  }

  /// Renews ahead of expiry: 60s before, or halfway through a short-lived
  /// token. Agora's own onTokenPrivilegeWillExpire (≈30s before) is a
  /// second trigger into the same [_renewToken] path.
  void _scheduleTokenRenewal(int? expiresInSeconds) {
    _tokenRenewTimer?.cancel();
    _tokenRenewTimer = null;
    if (expiresInSeconds == null || expiresInSeconds <= 0) return;
    final lead = expiresInSeconds - 60;
    final half = expiresInSeconds ~/ 2;
    final delaySeconds = lead > half ? lead : half;
    _tokenRenewTimer = Timer(
      Duration(seconds: delaySeconds < 1 ? 1 : delaySeconds),
      () {
        if (isClosed || _hasTerminated) return;
        unawaited(_renewToken());
      },
    );
  }

  /// Fetches a fresh token via /token and hands it to Agora. Returns false
  /// if no new token could be applied. A failed scheduled renewal retries
  /// shortly; actual expiry is handled by the AgoraTokenExpired branch.
  Future<bool> _renewToken() async {
    final session = state.session;
    if (session == null || _hasTerminated) return false;
    if (_isRenewingToken) return true;
    _isRenewingToken = true;
    try {
      final result = await _getCallTokenUseCase(session.callId);
      if (isClosed || _hasTerminated) return false;
      final token = result.fold((failure) {
        appLogger.d('❌ [CallCubit] Token renewal failed: ${failure.message}');
        return null;
      }, (t) => t);
      if (token == null) {
        _tokenRenewTimer?.cancel();
        _tokenRenewTimer = Timer(const Duration(seconds: 5), () {
          if (isClosed || _hasTerminated) return;
          unawaited(_renewToken());
        });
        return false;
      }
      if (token.uid != null && _localUid != null && token.uid != _localUid) {
        appLogger.d(
          '⚠️ [CallCubit] Renewed token is for uid ${token.uid}, but this '
          'device joined as $_localUid — renewing anyway.',
        );
      }
      // Renews the live connection's token in place — the call, its
      // activation state and the duration timer are left untouched.
      await _agoraService.renewToken(token.token);
      if (isClosed) return false;
      emit(
        state.copyWith(session: _applyToken(state.session ?? session, token)),
      );
      _scheduleTokenRenewal(token.expiresInSeconds);
      appLogger.d('🔑 [CallCubit] Agora token renewed');
      return true;
    } catch (e) {
      appLogger.d('❌ [CallCubit] Failed to renew Agora token: $e');
      return false;
    } finally {
      _isRenewingToken = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Agora Connection Single Entry Point
  // ---------------------------------------------------------------------------

  Future<void> _connectToAgora(
    CallSessionEntity session, {
    bool forceTokenUpdate = false,
  }) async {
    if (_joinRequested && !forceTokenUpdate) return;
    final role = _localRole;
    if (role == null || _hasTerminated) return;
    _joinRequested = true;

    emit(state.copyWith(mediaStatus: CallMediaStatus.requestingPermissions));

    final isVideo = session.callType.isVideo;
    final permissionResult = await _permissionService.requestPermissions(
      isVideoCall: isVideo,
    );

    if (isClosed || _hasTerminated) return;

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

      // The call is already accepted server-side — end it there too so the
      // peer isn't left waiting and nothing is ever activated.
      _failAndEndCall(errorMsg);
      return;
    }

    emit(state.copyWith(mediaStatus: CallMediaStatus.initializing));

    try {
      final agoraConfig = AgoraConfig.fromEnvironment(_envConfig);
      await _agoraService.initialize(agoraConfig.appId);

      if (isClosed || _hasTerminated) return;

      // The uid the server returned with the token (caller 1, host 2) —
      // the token is only valid for that uid. The role default only covers
      // a legacy response without agoraUid; never 0 or a random value.
      final uid = session.agoraUid ?? role.agoraUid;
      _localUid = uid;

      _subscribeToAgoraEvents();
      _subscribeToConnectivity();
      _watchDeviceAudio();

      emit(
        state.copyWith(
          mediaStatus: CallMediaStatus.joining,
          // Matches the engine's default route set in joinChannel; the
          // first AgoraAudioRouteChanged then confirms or corrects it.
          audio: state.audio.copyWith(
            route: isVideo ? CallAudioRoute.speaker : CallAudioRoute.earpiece,
          ),
        ),
      );

      await _agoraService.joinChannel(
        channelName: session.agoraChannel ?? '',
        rtcToken: session.agoraToken ?? '',
        uid: uid,
        isVideoCall: isVideo,
      );

      appLogger.d('✅ [CallCubit] Join channel request initiated (uid $uid)');
    } catch (e) {
      appLogger.d('❌ [CallCubit] Agora join failed: $e');
      _failAndEndCall('Unable to connect the call. You were not charged.');
    }
  }

  /// Mirrors the ringer mode / Do Not Disturb and connected audio devices
  /// into state for the call screen's status chips and route picker.
  void _watchDeviceAudio() {
    _deviceAudioWatcher.start(
      onSoundMode: (mode) {
        if (isClosed) return;
        emit(state.copyWith(audio: state.audio.copyWith(soundMode: mode)));
      },
      onDevices: (devices) {
        if (isClosed) return;
        emit(state.copyWith(audio: _withDevices(state.audio, devices)));
      },
    );
  }

  /// When the device behind the current route disappears, show the route
  /// the OS falls back to until the engine reports it.
  static CallAudioStatus _withDevices(
    CallAudioStatus audio,
    AudioOutputDevices devices,
  ) {
    var route = audio.route;
    if (route == CallAudioRoute.bluetooth && !devices.hasBluetooth) {
      route = devices.hasWiredHeadset
          ? CallAudioRoute.wiredHeadset
          : CallAudioRoute.earpiece;
    } else if (route == CallAudioRoute.wiredHeadset &&
        !devices.hasWiredHeadset) {
      route = CallAudioRoute.earpiece;
    }
    return audio.copyWith(devices: devices, route: route);
  }

  /// True when [remoteUid] belongs to the other participant rather than
  /// this device (both are scoped to the call's own channel).
  bool _isPeerUid(int remoteUid) => _localUid == null || remoteUid != _localUid;
  void _subscribeToAgoraEvents() {
    _agoraEventSub?.cancel();
    _agoraEventSub = _agoraService.events.listen((event) {
      if (isClosed) return;

      switch (event) {
        case AgoraLocalJoinSuccess():
          _readiness.localJoined = true;
          if (state.mediaStatus != CallMediaStatus.active) {
            emit(state.copyWith(mediaStatus: CallMediaStatus.waitingForRemote));
          }
          _maybeActivate();
          break;

        case AgoraLocalAudioPublished():
          _readiness.localAudioPublished = true;
          _maybeActivate();
          break;

        case AgoraRemoteAudioReceived(:final remoteUid):
          if (!_isPeerUid(remoteUid)) break;
          _readiness.remoteAudioReceived = true;
          _maybeActivate();
          break;

        case AgoraLocalMediaFailed(:final reason):
          appLogger.d('❌ [CallCubit] Local media failed: $reason');
          // Before activation this is a failed connection: end it without
          // billing. Once active, a transient capture error is left to the
          // connection-health handling below rather than dropping the call.
          if (!_hasActivated) {
            _failAndEndCall(
              'Unable to start your microphone or camera. '
              'You were not charged.',
            );
          }
          break;

        case AgoraRemoteUserJoined(:final remoteUid):
          if (!_isPeerUid(remoteUid)) break;

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

          emit(
            state.copyWith(
              mediaStatus: CallMediaStatus.active,
              isRemoteUserJoined: true,
              remoteUid: remoteUid,
            ),
          );

          // Activation is gated on this device's own media only; the peer
          // flags are informational. Guarded by _hasActivated /
          // _hasAcknowledgedMedia, so a rejoin after a network drop never
          // triggers a second /activate.
          _readiness.remoteJoined = true;
          _maybeActivate();
          break;

        case AgoraRemoteUserLeft(:final remoteUid, :final reason):
          if (_hasTerminated || !_isPeerUid(remoteUid)) break;

          if (reason == UserOfflineReasonType.userOfflineQuit) {
            // The peer left the channel voluntarily — this is Agora's own
            // signal that they tapped "End Call", not a dropped connection,
            // so there's no reason to show a "reconnecting" banner or wait
            // for the server-pushed `ended` socket event before reflecting
            // it here: end the call on this device immediately. Final
            // billing numbers (duration/billedUnits/points) don't need to
            // ride along with this transition — CallSummaryCubit fetches
            // and retries for those independently once the summary dialog
            // opens, using whatever `session` is already on hand as the
            // first-paint value.
            appLogger.d(
              '📴 [CallCubit] Remote participant left voluntarily. Ending call.',
            );
            _finalizeVoluntaryRemoteLeave();
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
            unawaited(_notifyServerEnd());
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
                  unawaited(_notifyServerEnd());
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
              _failAndEndCall(
                _hasActivated
                    ? 'The call ended because the media connection failed.'
                    : 'Unable to connect the call. You were not charged.',
              );
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
          appLogger.d(
            '⚠️ [CallCubit] Agora token will expire soon — renewing.',
          );
          unawaited(_renewToken());
          break;

        case AgoraTokenExpired():
          appLogger.d('❌ [CallCubit] Agora token expired.');
          unawaited(_recoverExpiredToken());
          break;

        case AgoraAudioRouteChanged(:final route):
          appLogger.d('🔈 [CallCubit] Audio route → $route');
          emit(state.copyWith(audio: state.audio.copyWith(route: route)));
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
    _connectivitySub = _connectivityService.onStatusChanged.listen((isOnline) {
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
    if (isClosed || _hasTerminated) return;
    // Media milestones from the dropped session no longer prove anything —
    // before activation they must be re-confirmed on the new join.
    if (!_hasActivated) _readiness.resetMedia();
    _joinRequested = false;
    await _connectToAgora(state.session ?? session, forceTokenUpdate: true);
  }

  /// Agora's onRequestToken: the token already expired. One immediate
  /// renewal attempt; if that fails the call can't continue, so end it.
  Future<void> _recoverExpiredToken() async {
    if (_hasTerminated) return;
    if (!_hasRecoveredExpiredToken) {
      _hasRecoveredExpiredToken = true;
      _isRenewingToken = false;
      final renewed = await _renewToken();
      if (renewed || isClosed || _hasTerminated) {
        if (renewed) _hasRecoveredExpiredToken = false;
        return;
      }
    }
    _failAndEndCall(
      _hasActivated
          ? 'The call ended because the session expired.'
          : 'Unable to connect the call. You were not charged.',
    );
  }

  // ---------------------------------------------------------------------------
  // Connection timeout & failure handling
  // ---------------------------------------------------------------------------

  /// Armed once the call is accepted (host: after accept; caller: on the
  /// `accepted` push). The server fails a call that isn't active within
  /// its connection timeout (60s) and pushes `failed`/`connection_timeout`;
  /// this backstop fires a little later in case that push was lost. It
  /// re-reads the call: a terminal status is applied as-is (no /end). If
  /// the server *still* reports the call as not ended, its own timeout
  /// evidently never ran (e.g. the backend restarted and lost the timer),
  /// so /end is sent once — otherwise the host stays "busy" indefinitely.
  /// If the server is unreachable, cleanup is local only. Never armed or
  /// fired once active.
  void _startConnectionTimeout() {
    if (_hasActivated || _hasTerminated) return;
    _connectionTimeoutTimer?.cancel();
    final seconds = state.session?.connectionTimeoutSeconds;
    final serverTimeout = Duration(
      seconds: seconds != null && seconds > 0
          ? seconds
          : _defaultServerConnectionTimeoutSeconds,
    );
    final backstop = serverTimeout + connectionTimeoutBackstopMargin;
    _connectionTimeoutTimer = Timer(backstop, () async {
      _connectionTimeoutTimer = null;
      if (isClosed || _hasTerminated || _hasActivated) return;
      appLogger.d(
        '⏳ [CallCubit] Not active ${backstop.inSeconds}s after acceptance '
        '(readiness: $_readiness) — reconciling with the server.',
      );
      final session = state.session;
      final serverStatus = await _reconcileWithServer();
      if (isClosed || _hasTerminated || _hasActivated) return;
      if (serverStatus != null && session != null) {
        appLogger.d(
          '⚠️ [CallCubit] Server still reports "$serverStatus" past its '
          'connection timeout — sending /end so the call is released.',
        );
        unawaited(_endStaleServerCall(session.callId));
      }
      _handleConnectionFailed(
        CallSocketEvent(
          callId: state.session?.callId ?? '',
          status: 'failed',
          endReason: 'connection_timeout',
        ),
      );
    });
  }

  /// Caller-only: ends the call at the server's `ringExpiresAt` (plus
  /// [ringExpiryGrace]) — or [noAnswerTimeout] after it starts ringing when
  /// there is none — if the host still hasn't answered. Cancelled by
  /// acceptance, activation and every teardown, so it can never close an
  /// accepted call.
  void _startNoAnswerTimer() {
    _noAnswerTimer?.cancel();
    final ringExpiresAt = state.session?.ringExpiresAt;
    final timeout = ringExpiresAt == null
        ? noAnswerTimeout
        : RingWindow.remaining(
                ringExpiresAt,
                _serverClock.now(),
                fallback: noAnswerTimeout,
              ) +
              ringExpiryGrace;
    appLogger.d(
      '⏱️ [CallCubit] Ringing until ${ringExpiresAt ?? 'fallback'} '
      '(${timeout.inMilliseconds} ms)',
    );
    _noAnswerTimer = Timer(timeout, () {
      _noAnswerTimer = null;
      if (isClosed || _hasTerminated) return;
      if (state.status != CallScreenStatus.ringing &&
          state.status != CallScreenStatus.initiating) {
        return;
      }
      _endUnanswered();
    });
  }

  /// Ends an unanswered call locally right away (screen shows "No answer")
  /// and sends /cancel in the background via [endCall]; the server then
  /// pushes `call_cancelled` to the host.
  void _endUnanswered() {
    appLogger.d(
      '⏱️ [CallCubit] Ring window expired with no answer — '
      'cancelling ${state.session?.callId}',
    );
    final session = state.session;
    if (session != null) {
      emit(
        state.copyWith(session: session.copyWith(endReason: noAnswerEndReason)),
      );
    }
    unawaited(endCall());
  }

  /// Local end reason for a call that rang out — see [_endUnanswered].
  static const String noAnswerEndReason = 'no_answer';

  /// Terminates a call that failed locally (media join/publish failure,
  /// permission denial, token failure, unrecoverable connection loss):
  /// releases Agora, media, listeners and timers, and tells the backend via
  /// /end. Activation is blocked from here on. Not used for the connection
  /// timeout — the server owns that (see [_handleConnectionFailed]).
  void _failAndEndCall(String message, {String endReason = 'media_failed'}) {
    if (_hasTerminated) return;
    _hasTerminated = true;
    _readiness.failed = true;

    final session = state.session;
    _stopTimer();
    emit(
      state.copyWith(
        // A call that was already billing ends with a summary; one that
        // never activated is a plain failure (nothing to summarise).
        status: _hasActivated
            ? CallScreenStatus.ended
            : CallScreenStatus.failed,
        mediaStatus: CallMediaStatus.failed,
        isRemoteUserJoined: false,
        isAwaitingPeerActivation: false,
        errorMessage: message,
        session: session?.copyWith(endReason: endReason),
        networkStatus: const CallNetworkStatus(),
      ),
    );
    unawaited(_agoraService.leaveChannel());
    _cleanupResources();
    unawaited(_notifyServerEnd(session: session));
  }

  /// Fire-and-forget /end for a locally-detected termination, so the
  /// server stops the call (and billing) and pushes the end to the peer.
  /// Skipped when the server is the one that ended it.
  Future<void> _notifyServerEnd({CallSessionEntity? session}) async {
    final target = session ?? state.session;
    if (target == null || _serverEndedCall) return;
    final result = await _endCallWithRetry(
      () => _endCallUseCase(target.callId),
    );
    result.fold(
      (failure) => appLogger.d(
        '❌ [CallCubit] /end after local failure failed: ${failure.message}',
      ),
      (_) => appLogger.d('✅ [CallCubit] Server notified of local call end'),
    );
  }

  // ---------------------------------------------------------------------------
  // Phase 3: Activation — both participants, once media is confirmed
  // ---------------------------------------------------------------------------

  /// Sends the first /activate once this device has joined and published
  /// local audio — never on a failed or terminated call. Repeat media
  /// callbacks are no-ops; retries are owned by [_scheduleActivateRetry]
  /// and [_reconcileWithServer].
  void _maybeActivate() {
    final session = state.session;
    if (session == null || _hasTerminated || _hasActivated) return;
    if (_hasRequestedActivation || !_readiness.isReady) return;
    unawaited(_activateCallSession(session.callId));
  }

  /// Calls POST /calls/:callId/activate once. The server answers `accepted`
  /// while it's still waiting for the peer's activation (no billing yet)
  /// and `active` once both have activated (billing started).
  ///
  /// Only a failed request is retried (network / 5xx, with backoff). After
  /// `accepted` the call is re-read via GET /calls/:id instead of
  /// re-POSTing, in case the `call_active` push is lost. A response that
  /// lands after the call ended is ignored.
  Future<void> _activateCallSession(String callId) async {
    if (_hasActivated ||
        _hasAcknowledgedMedia ||
        _isActivating ||
        _hasTerminated ||
        !_readiness.isReady) {
      return;
    }
    _isActivating = true;
    _hasRequestedActivation = true;

    appLogger.d(
      '⚡ [CallCubit] Calling HTTP activate for callId: $callId '
      '(attempt ${_activateRetryAttempts + 1})',
    );

    final result = await _activateCallUseCase(callId);
    _isActivating = false;
    if (isClosed || _hasTerminated || _hasActivated) return;

    result.fold(
      (failure) {
        appLogger.d('❌ [CallCubit] Activate failed: ${failure.message}');

        if (!_isRetryableFailure(failure)) {
          // e.g. a 4xx because the call already ended or failed server-side
          // — find out what the server knows instead of retrying blindly.
          // Retries are exhausted so that reconcile can't loop back into
          // another rejected /activate.
          _activateRetryAttempts = _maxActivateRetries;
          unawaited(_reconcileWithServer());
          return;
        }

        if (_activateRetryAttempts >= _maxActivateRetries) {
          appLogger.d(
            '❌ [CallCubit] Activate failed after $_maxActivateRetries '
            'retries — waiting on call_active or the server timeout.',
          );
          return;
        }

        _activateRetryAttempts++;
        final delay = Duration(seconds: _activateRetryAttempts * 2);
        appLogger.d(
          '⏳ [CallCubit] Retrying activate in ${delay.inSeconds}s '
          '(attempt $_activateRetryAttempts/$_maxActivateRetries)',
        );
        _scheduleActivateRetry(callId, delay);
      },
      (session) {
        final status = session.status.toLowerCase();
        final merged = _mergeActivationResponse(session);

        if (status == 'active') {
          appLogger.d('✅ [CallCubit] Activate → active (billing started)');
          _markActive(merged);
          return;
        }

        if (_routeTerminalEvent(_eventFromSession(session))) {
          appLogger.d('📴 [CallCubit] Activate → $status (call already over)');
          return;
        }

        // `accepted`: our side is acknowledged, the peer's isn't yet.
        // Billing hasn't started — keep media up and wait for call_active.
        appLogger.d(
          '⏳ [CallCubit] Activate → $status — waiting for the other '
          'participant (no billing yet)',
        );
        _hasAcknowledgedMedia = true;
        _activateRetryAttempts = 0;
        emit(state.copyWith(session: merged, isAwaitingPeerActivation: true));
        _startActivationPoll();
      },
    );
  }

  /// Network errors, rate limiting and 5xx are worth retrying; a 4xx means
  /// the server rejected this activation for a reason a retry won't fix.
  bool _isRetryableFailure(Failure failure) => switch (failure) {
    NetworkFailure() || RateLimitFailure() || UnknownFailure() => true,
    ServerFailure(:final statusCode) => statusCode == null || statusCode >= 500,
    _ => false,
  };

  void _scheduleActivateRetry(String callId, Duration delay) {
    _activateRetryTimer?.cancel();
    _activateRetryTimer = Timer(delay, () {
      _activateRetryTimer = null;
      if (isClosed || _hasTerminated || _hasActivated) return;
      unawaited(_activateCallSession(callId));
    });
  }

  /// While waiting for the peer after `accepted`, re-reads the call so a
  /// lost `call_active` / `call_ended` push can't strand this device. The
  /// server's connection timeout bounds how long this runs.
  void _startActivationPoll() {
    _activationPollTimer?.cancel();
    _activationPollTimer = Timer.periodic(_activationPollInterval, (_) {
      if (isClosed || _hasTerminated || _hasActivated) {
        _activationPollTimer?.cancel();
        _activationPollTimer = null;
        return;
      }
      unawaited(_reconcileWithServer());
    });
  }

  /// The /activate endpoint is a lightweight billing ack — it may omit
  /// connection-identity fields (callType, agoraChannel, agoraToken,
  /// hostId, callerId) that were already correctly set in state. Blindly
  /// replacing the session would null those out right as the remote video
  /// view renders, crashing AgoraVideoView / flipping video calls to the
  /// audio UI. Only the fields /activate is meant to update are merged in.
  CallSessionEntity _mergeActivationResponse(CallSessionEntity session) {
    final current = state.session;
    if (current == null) return session;
    return current.copyWith(
      status: session.status,
      duration: session.duration,
      billedUnits: session.billedUnits,
      totalPointsDebited: session.totalPointsDebited,
      ratePerMinute: session.ratePerMinute == 0 ? null : session.ratePerMinute,
      endReason: session.endReason.isNotEmpty ? session.endReason : null,
      activeAt: session.activeAt,
    );
  }

  /// Single, idempotent transition into the billed `active` state, reached
  /// from the /activate response, the `call_active` push, a
  /// `call_status_update`, or a reconcile. Never runs once media has failed
  /// or the call terminated. A repeat only corrects [_activeAt] if the
  /// first transition had to fall back to the local clock.
  void _markActive([CallSessionEntity? session]) {
    if (_hasTerminated || _readiness.failed) return;
    final serverActiveAt = session?.activeAt;

    if (_hasActivated) {
      if (serverActiveAt != null && !_activeAtFromServer) {
        _activeAt = serverActiveAt;
        _activeAtFromServer = true;
        emit(state.copyWith(durationSeconds: _elapsedSinceActive()));
      }
      return;
    }
    _hasActivated = true;
    // Server clock, not the device's: serverActiveAt is a server timestamp,
    // and a local fallback must be on the same clock so a later correction
    // (and _elapsedSinceActive) compares like with like.
    _activeAt = serverActiveAt ?? _serverClock.now();
    _activeAtFromServer = serverActiveAt != null;
    appLogger.d(
      '⏱️ [CallCubit] Active — activeAt=${_activeAt!.toIso8601String()} '
      '(${_activeAtFromServer ? 'server' : 'local fallback'}), '
      'server clock offset=${_serverClock.offset?.inMilliseconds ?? 'unsynced'} ms',
    );

    _activateRetryTimer?.cancel();
    _activateRetryTimer = null;
    _activationPollTimer?.cancel();
    _activationPollTimer = null;
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;
    _noAnswerTimer?.cancel();
    _noAnswerTimer = null;

    emit(
      state.copyWith(
        status: CallScreenStatus.active,
        session: (session ?? state.session)?.copyWith(
          status: 'active',
          activeAt: _activeAt,
        ),
        isAwaitingPeerActivation: false,
        durationSeconds: _elapsedSinceActive(),
      ),
    );
    _startTimer();
    _watchHostReleaseWhileActive();
  }

  /// Whole seconds since the server's `activeAt`, measured on
  /// [ServerClock] — never the raw device clock, which can be minutes off
  /// and would inflate (or freeze) the timer by exactly that much. Clamped
  /// at zero for the residual sub-second estimation error.
  int _elapsedSinceActive() {
    final activeAt = _activeAt;
    if (activeAt == null) return 0;
    final seconds = _serverClock.now().difference(activeAt).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  // ---------------------------------------------------------------------------
  // Socket reconnect reconciliation
  // ---------------------------------------------------------------------------

  /// A socket reconnect may have swallowed call events (accepted, active,
  /// ended…). The socket service re-subscribes to the call on reconnect;
  /// this re-reads the call from the server to catch up on what was missed.
  void _subscribeToSocketConnection() {
    _socketConnectionSub?.cancel();
    _socketConnectionSub = _presenceSocketService.connectionStatus.listen((
      connected,
    ) {
      if (!connected || isClosed || _hasTerminated) return;
      appLogger.d('🔄 [CallCubit] Socket reconnected — reconciling call state');
      unawaited(_reconcileWithServer());
    });
  }

  /// The server is the authority on whether a call is still running, but
  /// its `call_ended` push isn't guaranteed to arrive: it has been seen
  /// finalizing a call (billing stopped) without emitting one, leaving both
  /// devices in Agora with media flowing unbilled. What it *does* reliably
  /// push is the host's presence — the host flips back to not-busy the
  /// moment the server releases the call. Both participants receive that
  /// (the host its own update, the caller `host_status_update`), so seeing
  /// this call's host go free while still active triggers one re-read of
  /// the call; a terminal status there ends the call locally exactly like a
  /// `call_ended` push would (no /end sent). A presence blip that the
  /// server contradicts ("still active") changes nothing.
  void _watchHostReleaseWhileActive() {
    _hostPresenceSub?.cancel();
    final hostId = state.session?.hostId ?? '';
    if (hostId.isEmpty) return;
    _hostPresenceSub = _presenceSocketService.presenceUpdates.listen((
      presence,
    ) {
      if (presence.userId != hostId || presence.isOnCall) return;
      if (isClosed || _hasTerminated || !_hasActivated) return;
      if (_hostReleaseReconcileInFlight) return;
      appLogger.w(
        '⚠️ [CallCubit] Host released by server during an active call '
        '(status=${presence.status}, state=${presence.state}, busy=${presence.busy}) '
        'without call_ended — reconciling',
      );
      _hostReleaseReconcileInFlight = true;
      unawaited(
        _reconcileWithServer().whenComplete(
          () => _hostReleaseReconcileInFlight = false,
        ),
      );
    });
  }

  /// Follows the dialled host's presence from dial time until the next call
  /// starts, so the post-call "Call again" offers the call types the host
  /// has *now* — the host often changes state right as the call ends, and
  /// [_syncPresenceAfterCallEnd] requests a fresh snapshot at that moment.
  void _watchDialledHostPresence(String hostId) {
    _stopWatchingDialledHost();
    if (hostId.isEmpty) return;
    _dialledHostPresenceSub = _presenceSocketService.presenceUpdates.listen((
      presence,
    ) {
      final host = state.dialledHost;
      if (isClosed || host == null || presence.userId != host.id) return;
      emit(state.copyWith(dialledHost: host.copyWith(presence: presence)));
    });
  }

  void _stopWatchingDialledHost() {
    _dialledHostPresenceSub?.cancel();
    _dialledHostPresenceSub = null;
  }

  /// Re-reads the call and applies whatever the server says. Shared by the
  /// socket-reconnect catch-up, the post-`accepted` poll, the connection
  /// timeout backstop and the host-release watch. Returns the server's
  /// status, or null if it couldn't be read (or the call was already over
  /// locally).
  Future<String?> _reconcileWithServer() async {
    final session = state.session;
    if (session == null || _hasTerminated) return null;

    final result = await _callRepository.getCallDetails(session.callId);
    if (isClosed || _hasTerminated) return null;

    final server = result.fold((_) => null, (s) => s);
    if (server == null) return null;

    final status = server.status.toLowerCase();
    if (_routeTerminalEvent(_eventFromSession(server))) return status;

    switch (status) {
      case 'active':
        _markActive(_mergeActivationResponse(server));
      case 'accepted':
        if (_localRole == CallParticipantRole.caller &&
            (state.status == CallScreenStatus.ringing ||
                state.status == CallScreenStatus.initiating)) {
          _onCallAccepted(_eventFromSession(server));
        } else if (_activateRetryTimer == null &&
            _activateRetryAttempts < _maxActivateRetries) {
          // Covers an /activate whose response was lost or rejected while
          // the server still expects it; skipped once the server
          // acknowledged this device, and never ahead of a pending backoff.
          unawaited(_activateCallSession(session.callId));
        }
    }
    return status;
  }

  /// Best-effort /end for a call the server should already have closed on
  /// its own but still reports as running. Independent of cubit state (it
  /// may run after the call screen closed) and never emits.
  Future<void> _endStaleServerCall(String callId) async {
    final result = await _endCallWithRetry(() => _endCallUseCase(callId));
    result.fold(
      (failure) => appLogger.d(
        '❌ [CallCubit] /end for stale call $callId failed: ${failure.message}',
      ),
      (_) =>
          appLogger.d('✅ [CallCubit] Stale call $callId ended on the server'),
    );
  }

  static const Set<String> _terminalStatuses = {
    'ended',
    'failed',
    'rejected',
    'missed',
    'cancelled',
    'insufficient_balance',
  };

  bool _isTerminalStatus(String status) => _terminalStatuses.contains(status);

  /// Routes a terminal call event (from a push or an HTTP response) to the
  /// right handler. Returns false if it wasn't terminal. None of these
  /// handlers send /end — the server already ended the call.
  bool _routeTerminalEvent(CallSocketEvent event) {
    final status = event.status.toLowerCase();
    if (!_isTerminalStatus(status)) return false;
    if (status == 'failed' || event.endReason == 'connection_timeout') {
      _handleConnectionFailed(event);
    } else if (status == 'insufficient_balance' ||
        (status == 'ended' && event.endReason == 'insufficient_balance')) {
      _handleInsufficientBalance(event);
    } else {
      _handleCallTerminated(event);
    }
    return true;
  }

  CallSocketEvent _eventFromSession(CallSessionEntity session) {
    return CallSocketEvent(
      callId: session.callId,
      status: session.status.toLowerCase(),
      agoraChannel: session.agoraChannel,
      agoraToken: session.agoraToken,
      duration: session.duration,
      billedUnits: session.billedUnits,
      totalPointsDebited: session.totalPointsDebited,
      endReason: session.endReason.isEmpty ? null : session.endReason,
      activeAt: session.activeAt,
    );
  }

  /// Caller side: the host accepted. Start the connection-timeout backstop
  /// and join Agora with the credentials from the initiate response —
  /// /token is only a fallback when that response carried none.
  void _onCallAccepted(CallSocketEvent event) {
    _noAnswerTimer?.cancel();
    _noAnswerTimer = null;
    final updatedSession = _mergeSocketEvent(event);
    emit(
      state.copyWith(
        status: CallScreenStatus.connecting,
        session: updatedSession,
      ),
    );
    _startConnectionTimeout();

    final hasCredentials =
        updatedSession.agoraChannel?.isNotEmpty == true &&
        updatedSession.agoraToken?.isNotEmpty == true;
    if (hasCredentials) {
      _scheduleTokenRenewal(updatedSession.tokenExpiresInSeconds);
      unawaited(_connectToAgora(updatedSession));
    } else {
      unawaited(_fetchTokenAndConnect());
    }
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
        'billedUnits=${event.billedUnits}',
      );

      switch (event.status) {
        case 'accepted':
          // Host accepted → caller joins Agora with its initiate credentials.
          if (state.status == CallScreenStatus.ringing ||
              state.status == CallScreenStatus.initiating) {
            _onCallAccepted(event);
          }

        case 'active':
          // Server confirmed ACTIVE (both activated, billing started) via
          // call_active or call_status_update. Also catches this device up
          // if its own /activate response was lost. Safe to repeat.
          _markActive(_mergeSocketEvent(event));

        default:
          _routeTerminalEvent(event);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Phase 4: Ending the Call
  // ---------------------------------------------------------------------------

  /// Explicit user hang-up — the only user-driven path that sends /end.
  /// Server-pushed ends, rebuilds, minimise/restore and cubit disposal only
  /// clean up locally.
  Future<void> endCall() async {
    if (state.isCallEnded) {
      appLogger.d('[CallCubit] endCall ignored — call already ended');
      return;
    }
    if (_hasTerminated) {
      // Flagged terminated but the screen still shows a live call — some
      // path ended it without the UI following. Never ignore the tap here:
      // tear down locally and move the screen to `ended`.
      appLogger.w(
        '[CallCubit] endCall while terminated but status=${state.status} — '
        'forcing local teardown',
      );
      unawaited(_agoraService.leaveChannel());
      _stopTimer();
      emit(
        state.copyWith(
          status: CallScreenStatus.ended,
          isRemoteUserJoined: false,
          networkStatus: const CallNetworkStatus(),
        ),
      );
      _cleanupResources();
      return;
    }
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

    // Leave the Agora channel and stop the local timer immediately, in
    // parallel with (not gated behind) the HTTP call below. The peer's own
    // Agora SDK reports this as onUserOffline(quit) the moment this fires
    // (see AgoraService.leaveChannel's comment), which is what actually ends
    // the call on their screen — every other termination path in this class
    // (_handleCallTerminated, _handleInsufficientBalance, the 25s reconnect
    // timeouts) already leaves eagerly like this. Previously endCall() alone
    // deferred it until after the HTTP /end or /cancel call resolved, so a
    // slow or hung backend request (up to the 60s Dio timeout) left this
    // device's mic/camera streaming AND the peer's call running for just as
    // long, even though this user had already tapped "end call".
    unawaited(_agoraService.leaveChannel());
    _stopTimer();

    // End the call on this device immediately — nothing here waits on the
    // server. CallSummaryCubit independently fetches and retries for the
    // final duration/billedUnits/points once the summary dialog opens,
    // using whatever `session` is on hand as the first-paint value, so
    // there's no reason to hold the `ended` transition (or show a loader)
    // for the HTTP round-trip below.
    emit(
      state.copyWith(
        status: CallScreenStatus.ended,
        isRemoteUserJoined: false,
        // Clears a stale `isRemoteReconnecting`/quality banner left over
        // from right before this end — otherwise the status label keeps
        // showing "reconnecting" forever even though the call has ended,
        // since that check runs ahead of the ended-status check.
        networkStatus: const CallNetworkStatus(),
      ),
    );

    _cleanupResources();

    // Tell the server in the background, so it actually finalizes billing —
    // if the server already ended the call (socket event), skip this to
    // avoid a redundant POST /end after the peer already triggered it.
    if (!_serverEndedCall && session != null) {
      unawaited(
        _reconcileCallEndWithServer(
          session: session,
          currentStatus: currentStatus,
          awaitingRemoteConfirmation: awaitingRemoteConfirmation,
        ),
      );
    }
  }

  /// Talks to the server to actually end/cancel the call and returns the
  /// session with whatever billing fields it reports back merged in. Split
  /// out of [endCall] so that call site can wrap it in a single hard
  /// `.timeout()` backstop rather than relying solely on the per-request
  /// timeouts configured on each branch below.
  Future<CallSessionEntity> _reconcileCallEndWithServer({
    required CallSessionEntity session,
    required CallScreenStatus currentStatus,
    required bool awaitingRemoteConfirmation,
  }) async {
    if (awaitingRemoteConfirmation) {
      final detailsResult = await _callRepository.getCallDetails(
        session.callId,
      );
      final alreadyEnded = detailsResult.fold(
        (_) => false,
        (s) => s.status.toLowerCase() == 'ended',
      );
      if (alreadyEnded) {
        return detailsResult.fold(
          (_) => session,
          (updated) => _mergeBillingFields(session, updated),
        );
      }
      // Agora's offline report was a real network blip, not a hangup — the
      // server still thinks the call is active, so actually end it.
      final result = await _endCallWithRetry(
        () => _endCallUseCase(session.callId),
      );
      return result.fold(
        (_) => session,
        (updated) => _mergeBillingFields(session, updated),
      );
    } else if (currentStatus == CallScreenStatus.ringing ||
        currentStatus == CallScreenStatus.initiating) {
      // User cancelled before host answered — HTTP cancel
      final result = await _endCallWithRetry(
        () => _cancelCallUseCase(session.callId),
      );
      return result.fold(
        (_) => session,
        (updated) => _mergeBillingFields(session, updated),
      );
    } else if (currentStatus == CallScreenStatus.active ||
        currentStatus == CallScreenStatus.connecting) {
      // Active call ended locally — HTTP end triggers billing + push to peer
      final result = await _endCallWithRetry(
        () => _endCallUseCase(session.callId),
      );
      return result.fold(
        (_) => session,
        (updated) => _mergeBillingFields(session, updated),
      );
    }
    return session;
  }

  /// Runs an /end or /cancel HTTP call, retrying once more (with a short
  /// fixed delay, and a shorter per-attempt timeout set at the datasource
  /// level — see [CallRemoteDataSource.endCall]) if the first attempt fails.
  /// End-call is a short, idempotent, state-changing request — worth a quick
  /// retry rather than accepting the first transient failure and silently
  /// leaving the server thinking the call is still active/billing, even
  /// though this device has already left the Agora channel above.
  Future<Either<Failure, CallSessionEntity>> _endCallWithRetry(
    Future<Either<Failure, CallSessionEntity>> Function() action,
  ) async {
    const maxAttempts = 2;
    const retryDelay = Duration(seconds: 1);

    var result = await action();
    for (var attempt = 1; attempt < maxAttempts && result.isLeft(); attempt++) {
      if (isClosed) break;
      appLogger.d(
        '⚠️ [CallCubit] End/cancel call attempt $attempt failed — retrying.',
      );
      await Future.delayed(retryDelay);
      if (isClosed) break;
      result = await action();
    }
    return result;
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
      billedUnits: response.billedUnits,
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
    emit(
      state.copyWith(isMuted: _mediaControls.toggleMuteAudio(state.isMuted)),
    );
  }

  void toggleMuteVideo() {
    emit(
      state.copyWith(
        isVideoMuted: _mediaControls.toggleMuteVideo(state.isVideoMuted),
      ),
    );
  }

  /// One-tap speaker toggle: speaker off goes back to the best private
  /// route (Bluetooth, then wired headset, then earpiece).
  void toggleSpeakerphone() {
    final audio = state.audio;
    if (!audio.isSpeakerOn) {
      selectAudioRoute(CallAudioRoute.speaker);
    } else if (audio.devices.hasBluetooth) {
      selectAudioRoute(CallAudioRoute.bluetooth);
    } else if (audio.devices.hasWiredHeadset) {
      selectAudioRoute(CallAudioRoute.wiredHeadset);
    } else {
      selectAudioRoute(CallAudioRoute.earpiece);
    }
  }

  /// Shows [route] straight away; the engine's AgoraAudioRouteChanged then
  /// confirms it (or corrects it if the route couldn't be applied).
  void selectAudioRoute(CallAudioRoute route) {
    if (!state.audio.availableRoutes.contains(route)) return;
    emit(state.copyWith(audio: state.audio.copyWith(route: route)));
    _mediaControls.setAudioRoute(route);
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Finalizes the call immediately after the remote participant voluntarily
  /// left the Agora channel (a genuine hang-up), using whatever [session]
  /// data is already held locally — no server round-trip gates this
  /// transition. CallSummaryCubit independently fetches and retries for the
  /// final duration/billedUnits/points once the summary dialog opens.
  ///
  /// The peer's own /end is what closes the call server-side; if that
  /// request was lost the host would stay "busy", so the call is re-read
  /// after [peerQuitVerifyDelay] and ended from here if still running.
  void _finalizeVoluntaryRemoteLeave() {
    if (_hasTerminated) return;
    _hasTerminated = true;
    final callId = state.session?.callId;

    _stopTimer();
    emit(
      state.copyWith(
        status: CallScreenStatus.ended,
        mediaStatus: CallMediaStatus.ended,
        isRemoteUserJoined: false,
        networkStatus: const CallNetworkStatus(),
      ),
    );
    _agoraService.leaveChannel();
    _cleanupResources();
    if (callId != null && callId.isNotEmpty) {
      unawaited(_verifyServerEndedAfterPeerQuit(callId));
    }
  }

  /// See [_finalizeVoluntaryRemoteLeave]. Skipped once a server push already
  /// confirmed the end; runs even if the call screen has since closed.
  Future<void> _verifyServerEndedAfterPeerQuit(String callId) async {
    await Future<void>.delayed(peerQuitVerifyDelay);
    if (_serverEndedCall) return;
    final result = await _callRepository.getCallDetails(callId);
    final status = result.fold((_) => null, (s) => s.status.toLowerCase());
    if (status == null || _isTerminalStatus(status) || _serverEndedCall) return;
    appLogger.d(
      '⚠️ [CallCubit] Peer left but the server still reports "$status" — '
      'sending /end so the call is released.',
    );
    await _endStaleServerCall(callId);
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

  /// The call was accepted but never became active — the server failed it
  /// (`failed` / `connection_timeout`), or the backstop found it still not
  /// active. Nothing was charged. Cleans up locally only; never sends /end.
  void _handleConnectionFailed(CallSocketEvent event) {
    if (_hasTerminated) return;
    _hasTerminated = true;
    _serverEndedCall = true;
    _readiness.failed = true;

    _remoteReconnectTimer?.cancel();
    _remoteReconnectTimer = null;

    appLogger.d(
      '📴 [CallCubit] Call failed to connect (status=${event.status}, '
      'endReason=${event.endReason}) — cleaning up locally.',
    );
    _stopTimer();
    emit(
      state.copyWith(
        status: CallScreenStatus.failed,
        mediaStatus: CallMediaStatus.failed,
        isRemoteUserJoined: false,
        isAwaitingPeerActivation: false,
        errorMessage: couldNotConnectMessage,
        session: _mergeSocketEvent(
          event.endReason == null
              ? CallSocketEvent(
                  callId: event.callId,
                  status: event.status,
                  endReason: 'connection_timeout',
                )
              : event,
        ),
        networkStatus: const CallNetworkStatus(),
      ),
    );
    unawaited(_agoraService.leaveChannel());
    _cleanupResources();
  }

  void _handleInsufficientBalance(CallSocketEvent event) {
    if (_hasTerminated) {
      // The call already ended locally — typically the peer received this
      // same event first and left Agora, which reached us as
      // userOfflineQuit before our own socket push. Resources are already
      // released; just correct the end reason so the caller still gets the
      // recharge prompt. A server-driven end already carried its reason.
      if (!_serverEndedCall && state.status == CallScreenStatus.ended) {
        _serverEndedCall = true;
        emit(
          state.copyWith(
            status: CallScreenStatus.insufficientBalance,
            session: _mergeSocketEvent(event),
            errorMessage: insufficientBalanceEndedMessage,
          ),
        );
      }
      return;
    }
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
        errorMessage: insufficientBalanceEndedMessage,
        networkStatus: const CallNetworkStatus(),
      ),
    );
    _agoraService.leaveChannel();
    _cleanupResources();
  }

  /// POST /calls/initiate answers HTTP 400 "Insufficient wallet balance. You
  /// need at least N points." when the caller can't afford one second. The
  /// message is checked too, since a 400 can also mean the host is busy.
  bool _isInsufficientBalanceFailure(Failure failure) {
    final message = failure.message.toLowerCase();
    return message.contains('insufficient') && message.contains('balance');
  }

  CallSessionEntity _mergeSocketEvent(CallSocketEvent event) {
    final current = state.session;
    if (current == null) {
      return CallSessionEntity(
        callId: event.callId,
        status: event.status,
        callType: event.callType ?? CallType.audio,
        duration: event.duration ?? 0,
        billedUnits: event.billedUnits ?? 0,
        totalPointsDebited: event.totalPointsDebited ?? 0,
        ratePerMinute: 0,
        endReason: event.endReason ?? '',
        hostId: event.hostId ?? '',
        callerId: event.callerId ?? '',
        agoraChannel: event.agoraChannel,
        agoraToken: event.agoraToken,
        activeAt: event.activeAt,
      );
    }
    // Agora credentials are deliberately not taken from socket events: they
    // come only from this device's initiate/accept/token responses, and a
    // push may carry the other participant's token/channel.
    return current.copyWith(
      callId: event.callId.isNotEmpty ? event.callId : null,
      callerId: (event.callerId?.isNotEmpty == true) ? event.callerId : null,
      hostId: (event.hostId?.isNotEmpty == true) ? event.hostId : null,
      status: event.status,
      callType: event.callType ?? current.callType,
      duration: event.duration ?? current.duration,
      billedUnits: event.billedUnits ?? current.billedUnits,
      totalPointsDebited:
          event.totalPointsDebited ?? current.totalPointsDebited,
      endReason: event.endReason ?? current.endReason,
      activeAt: event.activeAt,
    );
  }

  /// Ticks the duration display from the server's `activeAt` rather than
  /// counting up locally, so both devices show the same billed time and a
  /// missed tick (e.g. app backgrounded) self-corrects.
  void _startTimer() {
    _durationTicker.start(() {
      if (isClosed) return;
      // A tick never moves the display backwards (e.g. the server clock
      // re-anchoring a fraction of a second earlier); only an explicit
      // activeAt correction in _markActive may lower it.
      emit(
        state.copyWith(
          durationSeconds: math.max(
            state.durationSeconds,
            _elapsedSinceActive(),
          ),
        ),
      );
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
    unawaited(_ringbackTone.stop());
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;
    _noAnswerTimer?.cancel();
    _noAnswerTimer = null;
    _tokenRenewTimer?.cancel();
    _tokenRenewTimer = null;
    _remoteReconnectTimer?.cancel();
    _remoteReconnectTimer = null;
    _localMidCallReconnectTimer?.cancel();
    _localMidCallReconnectTimer = null;
    _activateRetryTimer?.cancel();
    _activateRetryTimer = null;
    _activationPollTimer?.cancel();
    _activationPollTimer = null;
    _agoraEventSub?.cancel();
    _agoraEventSub = null;
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _deviceAudioWatcher.stop();
    _socketConnectionSub?.cancel();
    _socketConnectionSub = null;
    _hostPresenceSub?.cancel();
    _hostPresenceSub = null;
    _hostReleaseReconcileInFlight = false;
    _localRole = null;
    _localUid = null;
    _joinRequested = false;

    if (state.session != null) {
      _callRepository.unsubscribeCallSocket(state.session!.callId);
    }
    _socketEventSub?.cancel();
    _socketEventSub = null;
    _agoraService.dispose();
    unawaited(WakelockPlus.disable());
    unawaited(_proximity.setEnabled(false));
    _backgroundSync.stop();
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
    _forcedLogoutSub?.cancel();
    _backgroundActionSub?.cancel();
    _stopWatchingDialledHost();
    _cleanupResources();
    return super.close();
  }
}
