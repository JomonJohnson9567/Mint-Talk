import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/user_role.dart';
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

  HostDashCubit(
    this.getHostDashboardDataUseCase,
    this.getHostsUseCase,
    this.authRepository,
    this.presenceSocketService,
    this.tokenManager,
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
      appLogger.d('⚠️ [HostDashCubit] Cannot connect socket — no access token.');
      return;
    }
    appLogger.d('🔌 [HostDashCubit] Connecting presence socket...');
    presenceSocketService.connect(token);
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
  String _resolveAvatarUrl(String userId, HostEntity? profile, String fallback) {
    if (userId == _currentUserId && _selfAvatarUrl.isNotEmpty) return _selfAvatarUrl;
    if (profile != null && profile.avatarUrl.isNotEmpty) return profile.avatarUrl;
    return fallback;
  }

  /// Overwrites the placeholder name/imageUrl on any hosts that showed up
  /// via presence before their profile was known, now that it is.
  void _backfillProfilesIntoPresenceMap() {
    var changed = false;
    for (final entry in _presenceHostMap.entries) {
      final profile = _hostProfiles[entry.key];
      final resolvedName = _resolveName(entry.key, profile, entry.value.name);
      final resolvedImage =
          _resolveAvatarUrl(entry.key, profile, entry.value.imageUrl);
      if (resolvedName != entry.value.name || resolvedImage != entry.value.imageUrl) {
        _presenceHostMap[entry.key] = HostOnlineItemEntity(
          name: resolvedName,
          imageUrl: resolvedImage,
          status: entry.value.status,
        );
        changed = true;
      }
    }
    if (changed && !isClosed) {
      emit(state.copyWith(onlineHosts: _onlineHostsSnapshot('profile backfill')));
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
      'status: ${presence.status}, busy: ${presence.busy}',
    );

    if (presence.status == 'offline' && presence.busy != true) {
      // Host went offline — remove from the map
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
        status: presence.busy == true ? UserStatus.onCall : UserStatus.online,
      );
    }

    if (!isClosed) {
      emit(state.copyWith(
        onlineHosts: _onlineHostsSnapshot('presence event: ${presence.userId}'),
        isHostsLoading: false,
      ));
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

    // Ensure socket is connected (e.g. if host was offline or token wasn't ready earlier)
    await _connectSocket();

    final audioRate =
        await authRepository.getAudioRate() ?? _fallbackAudioRate;
    final videoRate =
        await authRepository.getVideoRate() ?? _fallbackVideoRate;

    if (isClosed) return;

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

    emit(
      state.copyWith(
        callFlowMode: HostDashCallFlowMode.waitingForNextCall,
        preferenceUpdateStatus: HostPreferenceUpdateStatus.success,
        isAudioSelected: updatedPreferences.isAudioAllowed,
        isVideoSelected: updatedPreferences.isVideoAllowed,
        isStartingCall: false,
        preferences: updatedPreferences,
      ),
    );
  }

  void pickupIncomingCall() {
    emit(state.copyWith(callFlowMode: HostDashCallFlowMode.waitingForNextCall));
  }

  void declineIncomingCall() {
    emit(state.copyWith(callFlowMode: HostDashCallFlowMode.waitingForNextCall));
  }

  /// Takes the host offline — disconnects the socket so the backend marks them offline in Redis.
  Future<void> stopWaitingForCalls() async {
    final audioRate =
        await authRepository.getAudioRate() ?? _fallbackAudioRate;
    final videoRate =
        await authRepository.getVideoRate() ?? _fallbackVideoRate;

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

    appLogger.d(
      '✅ [HostDashCubit] Socket disconnected — host going offline.',
    );

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
    await _presenceSub?.cancel();
    // Disconnect the socket — backend automatically marks host as offline.
    presenceSocketService.disconnect();
    appLogger.d('🔴 [HostDashCubit] Socket disconnected — host marked offline.');
    return super.close();
  }
}
