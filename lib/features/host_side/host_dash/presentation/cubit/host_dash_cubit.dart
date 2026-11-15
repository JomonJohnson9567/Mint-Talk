import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/user_role.dart';
import 'package:mint_talk/core/services/incoming_call_alert/i_incoming_call_alert_service.dart';
import 'package:mint_talk/core/services/permissions/call_permission_service.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/home_user_entity.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_presence_entity.dart';
import 'package:mint_talk/features/user_side/home/domain/usecases/get_hosts_usecase.dart';
import '../../domain/entities/host_online_item_entity.dart';
import '../../domain/entities/host_preferences_entity.dart';
import '../../domain/usecases/get_host_dashboard_data_usecase.dart';
import 'host_dash_state.dart';

@injectable
class HostDashCubit extends Cubit<HostDashState> {
  static const int _fallbackAudioRate = 60;
  static const int _fallbackVideoRate = 120;

  final GetHostDashboardDataUseCase getHostDashboardDataUseCase;
  final GetHostsUseCase getHostsUseCase;
  final AuthRepository authRepository;
  final IPresenceSocketService presenceSocketService;
  final TokenManager tokenManager;

  /// Android: keeps the host reachable while the app is minimized (the
  /// "You're online" foreground service) — see [startReceivingCalls].
  final IIncomingCallAlertService incomingCallAlertService;
  final ICallPermissionService callPermissionService;

  /// Tracks all online/on-call hosts seen from the socket, keyed by userId.
  final Map<String, HostOnlineItemEntity> _presenceHostMap = {};

  /// Name/avatar lookup fetched via REST, keyed by userId — the presence
  /// socket only ever sends userId + status, never a display name or image.
  final Map<String, HostEntity> _hostProfiles = {};

  /// The logged-in host's own userId — used to exclude their own presence
  /// events from their own "Hosts Online" grid.
  String? _currentUserId;

  /// The logged-in host's own name/avatar, read from the local auth cache
  /// rather than [_hostProfiles] — GET /hosts is a listing of OTHER hosts
  /// and may not include (or may lag behind) the caller's own record, so
  /// resolving self's card from it can never pick up a freshly-uploaded
  /// avatar. HostProfileEditCubit writes this cache immediately on every
  /// successful profile save, so it's always the freshest source for self.
  String _selfName = '';
  String _selfAvatarUrl = '';

  StreamSubscription<HostPresenceEntity>? _presenceSub;
  StreamSubscription<bool>? _connectionStatusSub;

  /// Gaps between automatic reconnect attempts while the host is waiting
  /// for calls and the socket is stalled (see
  /// [IPresenceSocketService.isStalled]). One attempt per entry; after the
  /// last one the reconnect banner stays up for a manual tap. Overridable in
  /// tests.
  static List<Duration> recoveryDelays = const [
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 10),
  ];

  Timer? _recoveryTimer;
  AppLifecycleListener? _lifecycleListener;

  HostDashCubit(
    this.getHostDashboardDataUseCase,
    this.getHostsUseCase,
    this.authRepository,
    this.presenceSocketService,
    this.tokenManager,
    this.incomingCallAlertService,
    this.callPermissionService,
  ) : super(const HostDashState()) {
    _init();
  }

  // ---------------------------------------------------------------------------
  // Init — connect socket + subscribe to presence
  // ---------------------------------------------------------------------------

  void _init() {
    // Subscribe to the presence stream BEFORE connecting so we never miss
    // events emitted during the handshake burst.
    _subscribeToPresence();
    _subscribeToConnectionStatus();
    _lifecycleListener = AppLifecycleListener(onResume: onAppResumed);
    _connectSocket();
    _loadCurrentUserId();
    unawaited(_loadSelfProfile());
    unawaited(_loadHostProfiles());

    // The backend retains whatever audio/video availability was last sent,
    // even across a dropped connection — so a fresh session (app open, hot
    // restart) would otherwise inherit "available" from before without the
    // host doing anything. Force it back to unavailable on every connect;
    // this call is buffered by PresenceSocketService and flushed as soon as
    // the handshake completes, so it lands even though the socket isn't
    // open yet. The host only becomes available again by tapping "Ready".
    presenceSocketService.updateAvailability(
      audioAvailable: false,
      videoAvailable: false,
    );
  }

  Future<void> _connectSocket() async {
    final token = await tokenManager.getValidAccessToken();
    if (token == null || token.isEmpty) {
      appLogger.d(
        '⚠️ [HostDashCubit] Cannot connect socket — no access token.',
      );
      return;
    }
    appLogger.d('🔌 [HostDashCubit] Connecting presence socket...');
    presenceSocketService.connect(token);
  }

  /// Waits for the socket to actually finish its handshake, up to [timeout].
  ///
  /// [presenceSocketService.connect] is fire-and-forget — it kicks off the
  /// handshake but returns immediately, it never waits for the `connect`
  /// event. Right after a cold app start (token fetch + TLS + auth can
  /// easily take a second or two) that handshake may still be in flight
  /// when the host taps "Ready", so calling [IPresenceSocketService.updateAvailability]
  /// right after `await _connectSocket()` was firing before the socket was
  /// actually connected — it would silently buffer, and the UI would flip
  /// to "Waiting for the call" as if the host were live even though the
  /// backend was never told they're available. This gives the handshake a
  /// bounded window to finish first; the caller still proceeds either way
  /// once it returns (never blocks the host indefinitely), but on a
  /// timeout [HostDashState.isSocketConnected] is left false so the
  /// waiting card's reconnect banner correctly reflects reality instead of
  /// silently lying.
  Future<bool> _waitUntilSocketConnected({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    // Ask the service, not our own state: connectionStatus only carries
    // transitions, so a socket that was already connected before this cubit
    // subscribed never pushes `true` here. Waiting on the stream in that case
    // stalled "Ready" for the full timeout and left the reconnect banner up
    // over a perfectly healthy socket.
    if (_syncConnectionStateFromService()) return true;
    try {
      return await presenceSocketService.connectionStatus
          .firstWhere((isConnected) => isConnected)
          .timeout(timeout, onTimeout: () => false);
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadCurrentUserId() async {
    _currentUserId = await authRepository.getUserId();
  }

  /// Refreshes [_selfName]/[_selfAvatarUrl] from the local auth cache — see
  /// the field doc comments for why this, rather than [_hostProfiles], is
  /// the source of truth for the logged-in host's own grid card.
  Future<void> _loadSelfProfile() async {
    final values = await Future.wait([
      authRepository.getFullName(),
      authRepository.getProfileImagePath(),
    ]);
    if (isClosed) return;
    _selfName = (values[0] ?? '').trim();
    _selfAvatarUrl = (values[1] ?? '').trim();
    // Covers the case where self is already showing in the grid (already
    // online) when a fresher name/avatar comes in — e.g. edited profile
    // without going offline first, then pulled to refresh.
    _backfillProfilesIntoPresenceMap();
  }

  // ---------------------------------------------------------------------------
  // Socket presence subscription (online hosts grid)
  // ---------------------------------------------------------------------------

  void _subscribeToPresence() {
    _presenceSub = presenceSocketService.presenceUpdates.listen(
      _onPresenceEvent,
      onError: (e) {
        appLogger.d('❌ [HostDashCubit] Presence socket error: $e');
      },
    );
  }

  /// Tracks whether the socket is actually live right now — surfaced to the
  /// UI as the "connection lost, tap to reconnect" banner on the waiting
  /// card. A host relying on their own card showing in "Hosts Online" as a
  /// health signal doesn't work once that card is (correctly) excluded from
  /// their own grid, so this reads the real transport state instead.
  void _subscribeToConnectionStatus() {
    _connectionStatusSub = presenceSocketService.connectionStatus.listen(
      _onConnectionStatusChanged,
    );
    // The stream doesn't replay, so seed from the real transport state. A
    // socket already connected by an earlier screen would otherwise leave
    // this cubit stuck on "disconnected" for its whole lifetime.
    _syncConnectionStateFromService();
  }

  /// Brings [HostDashState.isSocketConnected] in line with the service's
  /// actual transport state, running the same reconnect side effects as a
  /// live `connectionStatus` event when it flips to connected. Returns
  /// whether the socket is connected.
  bool _syncConnectionStateFromService() {
    final isConnected = presenceSocketService.isConnected;
    _onConnectionStatusChanged(isConnected);
    return isConnected;
  }

  void _onConnectionStatusChanged(bool isConnected) {
    if (isClosed || state.isSocketConnected == isConnected) return;

    appLogger.d(
      '🔌 [HostDashCubit] Socket connection status changed: '
      '${isConnected ? 'connected' : 'disconnected'}',
    );
    emit(state.copyWith(isSocketConnected: isConnected));

    if (isConnected) {
      _cancelRecovery();
    } else if (state.callFlowMode == HostDashCallFlowMode.waitingForNextCall) {
      _scheduleRecovery();
    }

    // A reconnect is a brand-new server-side socket session — if the host
    // was still waiting for calls when the drop happened, re-assert
    // availability and re-sync the online-hosts grid rather than leaving
    // both silently stale until the next manual pull-to-refresh.
    if (isConnected &&
        state.callFlowMode == HostDashCallFlowMode.waitingForNextCall) {
      presenceSocketService.updateAvailability(
        audioAvailable: state.isAudioSelected,
        videoAvailable: state.isVideoSelected,
      );
      presenceSocketService.requestPresenceSnapshot();
    }
  }

  // ---------------------------------------------------------------------------
  // Auto-recovery while waiting for calls
  // ---------------------------------------------------------------------------

  /// Starts (or restarts) the recovery loop. The socket_io Manager already
  /// retries transport drops by itself, but not a socket the server closed
  /// or rejected — that one stays down until someone calls connect(), and a
  /// host waiting for calls would silently be offline until they noticed
  /// the banner. Each tick only spends an attempt when the service reports
  /// [IPresenceSocketService.isStalled]; while the Manager is still backing
  /// off on its own, the tick just checks again later.
  void _scheduleRecovery({int attempt = 0, Duration? firstDelay}) {
    _recoveryTimer?.cancel();
    if (isClosed || attempt >= recoveryDelays.length) {
      if (attempt >= recoveryDelays.length) {
        appLogger.d(
          '⚠️ [HostDashCubit] Auto-reconnect gave up after $attempt '
          'attempt(s) — waiting for a manual Reconnect.',
        );
      }
      return;
    }
    _recoveryTimer = Timer(firstDelay ?? recoveryDelays[attempt], () {
      if (isClosed ||
          state.callFlowMode != HostDashCallFlowMode.waitingForNextCall ||
          _syncConnectionStateFromService()) {
        return;
      }
      if (!presenceSocketService.isStalled) {
        // The service is still recovering by itself — check again later
        // without spending an attempt.
        _scheduleRecovery(attempt: attempt);
        return;
      }
      appLogger.d(
        '🔁 [HostDashCubit] Socket stalled while waiting for calls — '
        'auto-reconnect attempt ${attempt + 1}/${recoveryDelays.length}.',
      );
      unawaited(_connectSocket());
      _scheduleRecovery(attempt: attempt + 1);
    });
  }

  void _cancelRecovery() {
    _recoveryTimer?.cancel();
    _recoveryTimer = null;
  }

  /// App came back to the foreground. A long background stretch is when the
  /// socket is most likely to have been closed under us, so re-check now
  /// with a fresh attempt budget rather than waiting for the next tick.
  @visibleForTesting
  void onAppResumed() {
    if (isClosed ||
        state.callFlowMode != HostDashCallFlowMode.waitingForNextCall) {
      return;
    }
    if (_syncConnectionStateFromService()) return;
    _scheduleRecovery(firstDelay: Duration.zero);
  }

  /// Fetches the host roster via REST purely to resolve display name/avatar
  /// by userId — the presence socket payload never includes them (only
  /// userId, status, busy). Backfills any hosts already added to the grid
  /// from a presence event that arrived before this REST call finished.
  Future<void> _loadHostProfiles() async {
    final result = await getHostsUseCase(const GetHostsParams());
    if (isClosed) return;

    result.fold(
      (failure) => appLogger.d(
        '⚠️ [HostDashCubit] Failed to fetch host profiles: ${failure.message}',
      ),
      (paginatedHosts) {
        // TODO: not skipping the logged-in host's own profile here while
        // their own card is temporarily shown in the grid for testing (see
        // the matching TODO in _onPresenceEvent). Re-add
        // `if (host.id == _currentUserId) continue;` when that's reverted.
        for (final host in paginatedHosts.items) {
          _hostProfiles[host.id] = host;
        }
        _backfillProfilesIntoPresenceMap();
      },
    );
  }

  /// Resolves a userId's display name — self's own local cache wins over
  /// the REST-fetched [_hostProfiles] entry, which falls back to [fallback].
  String _resolveName(String userId, HostEntity? profile, String fallback) {
    if (userId == _currentUserId && _selfName.isNotEmpty) return _selfName;
    if (profile != null && profile.fullName.isNotEmpty) return profile.fullName;
    return fallback;
  }

  /// Resolves a userId's avatar — see [_resolveName] for the precedence.
  String _resolveAvatarUrl(
    String userId,
    HostEntity? profile,
    String fallback,
  ) {
    if (userId == _currentUserId && _selfAvatarUrl.isNotEmpty)
      return _selfAvatarUrl;
    if (profile != null && profile.avatarUrl.isNotEmpty)
      return profile.avatarUrl;
    return fallback;
  }

  /// Overwrites the placeholder name/imageUrl on any hosts that showed up
  /// via presence before their profile was known, now that it is.
  void _backfillProfilesIntoPresenceMap() {
    var changed = false;
    for (final entry in _presenceHostMap.entries) {
      final profile = _hostProfiles[entry.key];
      final resolvedName = _resolveName(entry.key, profile, entry.value.name);
      final resolvedImage = _resolveAvatarUrl(
        entry.key,
        profile,
        entry.value.imageUrl,
      );
      if (resolvedName != entry.value.name ||
          resolvedImage != entry.value.imageUrl) {
        _presenceHostMap[entry.key] = HostOnlineItemEntity(
          name: resolvedName,
          imageUrl: resolvedImage,
          status: entry.value.status,
        );
        changed = true;
      }
    }
    if (changed && !isClosed) {
      emit(
        state.copyWith(onlineHosts: _onlineHostsSnapshot('profile backfill')),
      );
    }
  }

  /// Snapshots the current "Hosts Online" grid contents and logs it —
  /// useful for tracing exactly what data (name/status/avatarUrl) reached
  /// the grid and which trigger produced it.
  List<HostOnlineItemEntity> _onlineHostsSnapshot(String reason) {
    final hosts = _presenceHostMap.values.toList();
    final lines = hosts
        .map((h) => '  • ${h.name} | ${h.status} | ${h.imageUrl}')
        .join('\n');
    appLogger.d(
      '🖼️ [HostDashCubit] Hosts Online grid ($reason) — ${hosts.length} host(s)'
      '${hosts.isEmpty ? '' : ':\n$lines'}',
    );
    return hosts;
  }

  void _onPresenceEvent(HostPresenceEntity presence) {
    if (isClosed) return;

    // TODO: currently showing the logged-in host's own card in their "Hosts
    // Online" grid for easier manual testing of availability. Re-enable
    // this filter (`if (presence.userId == _currentUserId) return;`) once
    // testing is done — a host doesn't need to see themselves listed among
    // other online hosts.

    final isSelf = presence.userId == _currentUserId;
    appLogger.d(
      '🟢 [HostDashCubit] Presence event — '
      'userId: ${presence.userId}${isSelf ? ' (self)' : ''}, '
      'status: ${presence.status}, state: ${presence.state}, '
      'busy: ${presence.busy}',
    );

    if (presence.status != 'online') {
      // Host went offline — remove from the map, even if a stale
      // `state: busy` is still attached (see HostPresenceEntity.isOnCall).
      _presenceHostMap.remove(presence.userId);
    } else {
      // Online or busy — upsert, preferring self's own cache / the
      // REST-resolved profile over whatever placeholder was already there.
      final profile = _hostProfiles[presence.userId];
      final existing = _presenceHostMap[presence.userId];
      _presenceHostMap[presence.userId] = HostOnlineItemEntity(
        name: _resolveName(
          presence.userId,
          profile,
          existing?.name ?? presence.userId,
        ),
        imageUrl: _resolveAvatarUrl(
          presence.userId,
          profile,
          existing?.imageUrl ?? '',
        ),
        status: presence.isOnCall ? UserStatus.onCall : UserStatus.online,
      );
    }

    if (!isClosed) {
      emit(
        state.copyWith(
          onlineHosts: _onlineHostsSnapshot(
            'presence event: ${presence.userId}',
          ),
          isHostsLoading: false,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Dashboard data
  // ---------------------------------------------------------------------------

  Future<void> loadDashboardData() async {
    emit(state.copyWith(status: HostDashStatus.loading, isHostsLoading: true));

    final dashboardResult = await getHostDashboardDataUseCase(NoParams());

    if (isClosed) return;

    dashboardResult.fold(
      (failure) => emit(
        state.copyWith(
          status: HostDashStatus.failure,
          errorMessage: failure.message,
          isHostsLoading: false,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: HostDashStatus.success,
          dashboardData: data,
          onlineHosts: _onlineHostsSnapshot('initial load'),
          isHostsLoading: false,
        ),
      ),
    );
  }

  /// Re-fetches dashboard data for pull-to-refresh. Unlike [loadDashboardData],
  /// this never flips [HostDashState.status] to loading, so the current
  /// content stays visible under the refresh spinner instead of being
  /// replaced by the skeleton.
  Future<void> refreshDashboardData() async {
    unawaited(_loadSelfProfile());
    unawaited(_loadHostProfiles());
    // A live availability broadcast can be missed by an already-connected
    // socket — this forces a fresh full re-sync of the "Hosts Online" grid
    // as a manual recovery path, independent of whatever live update may
    // or may not have arrived.
    presenceSocketService.requestPresenceSnapshot();
    final dashboardResult = await getHostDashboardDataUseCase(NoParams());

    if (isClosed) return;

    dashboardResult.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (data) => emit(
        state.copyWith(
          status: HostDashStatus.success,
          dashboardData: data,
          onlineHosts: _onlineHostsSnapshot('refresh'),
          isHostsLoading: false,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Call flow actions
  // ---------------------------------------------------------------------------

  void toggleVideoCall() {
    if (state.callFlowMode != HostDashCallFlowMode.selecting ||
        state.isStartingCall) {
      return;
    }
    emit(state.copyWith(isVideoSelected: !state.isVideoSelected));
  }

  void toggleAudioCall() {
    if (state.callFlowMode != HostDashCallFlowMode.selecting ||
        state.isStartingCall) {
      return;
    }
    emit(state.copyWith(isAudioSelected: !state.isAudioSelected));
  }

  /// Puts the host online and updates their audio/video availability via socket.
  Future<void> startReceivingCalls() async {
    if (!state.isAnyCallSelected || state.isStartingCall) {
      return;
    }

    final role = await authRepository.getRole();
    if (role.toUserRole() != UserRole.host) {
      emit(
        state.copyWith(
          preferenceUpdateStatus: HostPreferenceUpdateStatus.failure,
          errorMessage: 'Please log in again with your host account.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isStartingCall: true,
        preferenceUpdateStatus: HostPreferenceUpdateStatus.loading,
      ),
    );

    // The incoming-call notification is how a minimized app rings —
    // without the permission calls still ring, but only in the app.
    final notificationsAllowed = await callPermissionService
        .ensureNotificationPermission();
    if (isClosed) return;

    // Ensure socket is connected (e.g. if host was offline or token wasn't ready earlier)
    await _connectSocket();

    final audioRate = await authRepository.getAudioRate() ?? _fallbackAudioRate;
    final videoRate = await authRepository.getVideoRate() ?? _fallbackVideoRate;

    if (isClosed) return;

    // Give the handshake a bounded window to actually finish — see
    // _waitUntilSocketConnected doc for why this matters right after a
    // cold app start.
    final isConnected = await _waitUntilSocketConnected();
    if (isClosed) return;

    if (!isConnected) {
      appLogger.d(
        '⚠️ [HostDashCubit] Still not connected after waiting to go '
        'online — proceeding anyway; update_availability will flush once '
        'the socket connects, and the waiting card will show the '
        'reconnect banner in the meantime.',
      );
    }

    // Emit socket update_availability
    presenceSocketService.updateAvailability(
      audioAvailable: state.isAudioSelected,
      videoAvailable: state.isVideoSelected,
    );

    // Persist selections locally so they survive app restarts.
    await Future.wait([
      authRepository.saveAudioRate(audioRate),
      authRepository.saveVideoRate(videoRate),
      authRepository.saveIsAudioAllowed(state.isAudioSelected),
      authRepository.saveIsVideoAllowed(state.isVideoSelected),
    ]);

    if (isClosed) return;

    final updatedPreferences = HostPreferencesEntity(
      audioRate: audioRate,
      videoRate: videoRate,
      isAudioAllowed: state.isAudioSelected,
      isVideoAllowed: state.isVideoSelected,
    );

    // Re-read the transport state: the handshake may have finished (or
    // failed) after the bounded wait above returned.
    final isConnectedNow = _syncConnectionStateFromService();

    emit(
      state.copyWith(
        callFlowMode: HostDashCallFlowMode.waitingForNextCall,
        preferenceUpdateStatus: HostPreferenceUpdateStatus.success,
        isAudioSelected: updatedPreferences.isAudioAllowed,
        isVideoSelected: updatedPreferences.isVideoAllowed,
        isStartingCall: false,
        preferences: updatedPreferences,
        notificationsBlocked: !notificationsAllowed,
      ),
    );

    // Entering "waiting" while already disconnected produces no new
    // connectionStatus transition, so start the recovery loop here too.
    if (!isConnectedNow) _scheduleRecovery();

    // Keeps the process — and the presence socket — alive while the app is
    // minimized, so incoming calls still arrive and ring. Started here while
    // the host is in the app: Android refuses a background start.
    unawaited(
      incomingCallAlertService.startHostStandby(
        audio: updatedPreferences.isAudioAllowed,
        video: updatedPreferences.isVideoAllowed,
      ),
    );
  }

  /// Manually re-opens the socket after a drop — bound to the "Reconnect"
  /// tap on the waiting card's connection-lost banner. No-op if already
  /// connected; [_connectSocket] itself guards against a duplicate in-flight
  /// attempt, so this is safe to tap repeatedly.
  Future<void> retryConnection() async {
    // The socket may already be live while our state says otherwise. In
    // that case connect() takes its "already connected" branch and emits
    // nothing, so the banner could never clear. Sync instead; that also
    // re-asserts availability and re-requests the presence snapshot.
    if (_syncConnectionStateFromService()) return;
    appLogger.d('🔁 [HostDashCubit] Manual reconnect requested.');
    await _connectSocket();
  }

  void pickupIncomingCall() {
    emit(state.copyWith(callFlowMode: HostDashCallFlowMode.waitingForNextCall));
  }

  void declineIncomingCall() {
    emit(state.copyWith(callFlowMode: HostDashCallFlowMode.waitingForNextCall));
  }

  /// Takes the host offline — disconnects the socket so the backend marks them offline in Redis.
  Future<void> stopWaitingForCalls() async {
    _cancelRecovery();
    final audioRate = await authRepository.getAudioRate() ?? _fallbackAudioRate;
    final videoRate = await authRepository.getVideoRate() ?? _fallbackVideoRate;

    emit(
      state.copyWith(
        callFlowMode: HostDashCallFlowMode.selecting,
        isAudioSelected: false,
        isVideoSelected: false,
      ),
    );

    await Future.wait([
      authRepository.saveIsAudioAllowed(false),
      authRepository.saveIsVideoAllowed(false),
    ]);

    // Simply call socket.disconnect() when staff explicitly toggles to "Go Offline"
    presenceSocketService.disconnect();
    unawaited(incomingCallAlertService.stopHostStandby());

    appLogger.d('✅ [HostDashCubit] Socket disconnected — host going offline.');

    // Disconnecting kills the whole presence stream, so no further
    // "offline" event will ever arrive for us over this connection —
    // update the local map immediately instead of leaving a stale
    // "online" entry sitting in the grid until the next reconnect.
    if (!isClosed &&
        _currentUserId != null &&
        _presenceHostMap.remove(_currentUserId) != null) {
      emit(
        state.copyWith(onlineHosts: _onlineHostsSnapshot('self went offline')),
      );
    }

    if (!isClosed) {
      emit(
        state.copyWith(
          preferences: HostPreferencesEntity(
            audioRate: audioRate,
            videoRate: videoRate,
            isAudioAllowed: false,
            isVideoAllowed: false,
          ),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  Future<void> close() async {
    _cancelRecovery();
    _lifecycleListener?.dispose();
    await _presenceSub?.cancel();
    await _connectionStatusSub?.cancel();
    // Disconnect the socket — backend automatically marks host as offline.
    presenceSocketService.disconnect();
    unawaited(incomingCallAlertService.stopHostStandby());
    appLogger.d(
      '🔴 [HostDashCubit] Socket disconnected — host marked offline.',
    );
    return super.close();
  }
}
