import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_presence_entity.dart';
import 'package:mint_talk/features/user_side/home/domain/usecases/connect_host_presence_usecase.dart';
import 'package:mint_talk/features/user_side/home/domain/usecases/disconnect_host_presence_usecase.dart';
import 'package:mint_talk/features/user_side/home/domain/usecases/watch_host_presence_usecase.dart';

import 'package:mint_talk/features/user_side/home/domain/usecases/get_hosts_usecase.dart';
import 'package:mint_talk/features/user_side/favorites/domain/usecases/add_favorite_usecase.dart';
import 'package:mint_talk/features/user_side/favorites/domain/usecases/remove_favorite_usecase.dart';
import 'package:mint_talk/features/user_side/favorites/domain/usecases/get_favorite_hosts_usecase.dart';

import 'home_state.dart';

/// Duration to wait for the initial socket snapshot burst before giving up.
/// If no [host_status_update] events arrive within this window, we transition
/// out of the loading state and show an empty list.
const _kInitialSnapshotTimeout = Duration(milliseconds: 2500);

@injectable
class HomeCubit extends Cubit<HomeState> {
  final WatchHostPresenceUseCase _watchPresence;
  final ConnectHostPresenceUseCase _connectPresence;
  final DisconnectHostPresenceUseCase _disconnectPresence;
  final GetHostsUseCase _getHostsUseCase;
  final AuthRepository _authRepository;
  final TokenManager _tokenManager;
  final GetFavoriteHostsUseCase _getFavoriteHostsUseCase;
  final AddFavoriteUseCase _addFavoriteUseCase;
  final RemoveFavoriteUseCase _removeFavoriteUseCase;

  /// All hosts received from the socket & API, keyed by host ID for O(1) patching.
  final Map<String, HostEntity> _allHosts = {};

  /// Backend-sourced favourite hosts (Favorites tab), fetched via [GetFavoriteHostsUseCase].
  List<HostEntity> _favoriteHosts = [];

  /// IDs of [_favoriteHosts] — kept for O(1) heart-icon state lookup on cards
  /// in the Active/Offline tabs.
  Set<String> _favoriteIds = {};

  /// Whether we have received at least one socket event or API response.
  bool _initialSnapshotReceived = false;

  StreamSubscription<HostPresenceEntity>? _presenceSub;
  Timer? _snapshotTimer;

  HomeCubit(
    this._watchPresence,
    this._connectPresence,
    this._disconnectPresence,
    this._getHostsUseCase,
    this._authRepository,
    this._tokenManager,
    this._getFavoriteHostsUseCase,
    this._addFavoriteUseCase,
    this._removeFavoriteUseCase,
  ) : super(const HomeState()) {
    _init();
  }

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  Future<void> _init() async {
    // 1. Subscribe FIRST so we never miss the initial burst emitted right after
    //    the socket handshake completes.
    _subscribeToPresence();

    // 2. Connect socket
    _connectSocket();

    // 3. Kick off snapshot timeout and API / local data loads in parallel.
    _startSnapshotTimeout();
    await Future.wait<void>([
      _loadInitialHosts(),
      _loadCallRates(),
      _loadFavorites(),
    ]);
    if (!isClosed) {
      _emitFilteredState();
    }
  }

  Future<void> _loadInitialHosts() async {
    final result = await _getHostsUseCase(const GetHostsParams());
    if (isClosed) return;


    result.fold(
      (failure) {
        appLogger.d(
          '⚠️ [HomeCubit] Failed to fetch host list via REST API: ${failure.message}',
        );
      },
      (paginatedHosts) {
        appLogger.d(
          '✅ [HomeCubit] REST API returned ${paginatedHosts.items.length} hosts',
        );
        for (final host in paginatedHosts.items) {
          final existing = _allHosts[host.id];
          if (existing != null) {
            _allHosts[host.id] = _mergeHostProfile(existing, host);
          } else {
            _allHosts[host.id] = host;
          }
        }
        if (!_initialSnapshotReceived) {
          _initialSnapshotReceived = true;
          _snapshotTimer?.cancel();
        }
        _emitFilteredState(isLoading: false);
      },
    );
  }

  Future<void> _loadCallRates() async {
    final rates = await Future.wait<int?>([
      _authRepository.getAudioRate(),
      _authRepository.getVideoRate(),
    ]);
    if (isClosed) return;
    emit(state.copyWith(audioRate: rates[0], videoRate: rates[1]));
  }

  Future<void> _loadFavorites() async {
    final result = await _getFavoriteHostsUseCase(const GetFavoriteHostsParams(page: 1, limit: 50));
    if (isClosed) return;

    result.fold(
      (failure) {
        appLogger.d('⚠️ [HomeCubit] Failed to fetch favorite hosts: ${failure.message}');
      },
      (paginated) {
        _favoriteHosts = paginated.items;
        _favoriteIds = paginated.items.map((h) => h.id).toSet();
      },
    );
  }

  Future<void> _connectSocket() async {
    final token = await _tokenManager.getValidAccessToken();
    if (token == null || token.isEmpty) return;
    _connectPresence(token);
  }

  void _subscribeToPresence() {
    _presenceSub = _watchPresence().listen(
      _onPresenceEvent,
      onError: _onPresenceError,
    );
  }

  /// Fallback — stop the skeleton if no socket events arrive in time.
  void _startSnapshotTimeout() {
    _snapshotTimer = Timer(_kInitialSnapshotTimeout, () {
      if (!_initialSnapshotReceived && !isClosed) {
        appLogger.d('⚠️ [HomeCubit] Snapshot timeout — no socket events received.');
        emit(state.copyWith(isLoading: false));
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Socket event handler
  // ---------------------------------------------------------------------------

  void _onPresenceEvent(HostPresenceEntity presence) {
    if (isClosed) return;

    appLogger.d(
      '🟢 [HomeCubit] host_status_update received — '
      'userId: ${presence.userId}, status: ${presence.status}, '
      'busy: ${presence.busy}, state: ${presence.state}, '
      'audio: ${presence.audioAvailable}, video: ${presence.videoAvailable}',
    );

    // Mark end of initial loading on first event.
    if (!_initialSnapshotReceived) {
      _initialSnapshotReceived = true;
      _snapshotTimer?.cancel();
    }

    final existingHost = _allHosts[presence.userId];

    if (existingHost != null) {
      _allHosts[presence.userId] = _buildPatchedHost(existingHost, presence);
      appLogger.d('   ↳ Patched existing host: ${existingHost.fullName}');
    } else {
      _allHosts[presence.userId] = _buildHostFromPresence(presence);
      appLogger.d('   ↳ Created stub host from presence (no profile data yet)');
    }

    // Keep the Favorites tab's own list (sourced separately from the backend)
    // live too, since it's no longer derived from _allHosts.
    final favoriteIndex = _favoriteHosts.indexWhere((h) => h.id == presence.userId);
    if (favoriteIndex != -1) {
      _favoriteHosts[favoriteIndex] =
          _buildPatchedHost(_favoriteHosts[favoriteIndex], presence);
    }

    appLogger.d(
      '   ↳ Total in map: ${_allHosts.length} | '
      'Active: ${_filterHosts(HomeTab.active).length}',
    );

    // Log the entire socket-managed host list data for verification
    appLogger.d('📋 [HomeCubit] Full socket host list data:');
    _allHosts.forEach((id, host) {
      appLogger.d(
        '      - Host [id: $id, name: ${host.fullName}, presenceState: ${host.presence?.state}, '
        'busy: ${host.presence?.busy}, audio: ${host.isAudioAllowed}, video: ${host.isVideoAllowed}]',
      );
    });


    _emitFilteredState(isLoading: false);

  }

  void _onPresenceError(Object error) {
    if (isClosed) return;
    _snapshotTimer?.cancel();
    emit(
      state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pull-to-refresh
  // ---------------------------------------------------------------------------

  /// Re-fetches the host list, call rates and favourites. Used by
  /// pull-to-refresh — deliberately does not flip [HomeState.isLoading],
  /// so the current list stays visible under the refresh spinner instead
  /// of being replaced by the skeleton.
  Future<void> refresh() async {
    await Future.wait<void>([
      _loadInitialHosts(),
      _loadCallRates(),
      _loadFavorites(),
    ]);
    if (!isClosed) {
      _emitFilteredState();
    }
  }

  // ---------------------------------------------------------------------------
  // Tab & Favourite actions
  // ---------------------------------------------------------------------------

  void changeTab(HomeTab tab) {
    _emitFilteredState(selectedTab: tab);
  }

  Future<void> toggleFavorite(String hostId) async {
    final isCurrentlyFavorite = _favoriteIds.contains(hostId);
    final params = FavoriteHostParams(hostId: hostId);

    final result = isCurrentlyFavorite
        ? await _removeFavoriteUseCase(params)
        : await _addFavoriteUseCase(params);
    if (isClosed) return;

    final succeeded = result.fold(
      (failure) {
        appLogger.d('⚠️ [HomeCubit] Failed to toggle favorite: ${failure.message}');
        return false;
      },
      (_) => true,
    );

    if (succeeded) {
      await _loadFavorites();
    }
    if (!isClosed) {
      _emitFilteredState();
    }
  }

  void notifyUser(HostEntity host) {
    final name = host.fullName.isNotEmpty ? host.fullName : 'this host';
    final isBusy =
        host.presence?.busy == true || host.presence?.state == 'busy';

    final message = isBusy
        ? 'We will notify you when $name is free'
        : 'We will notify you when $name is online';

    final type = isBusy ? NotificationType.info : NotificationType.success;

    emit(
      state.copyWith(
        notificationMessage: message,
        notificationType: type,
        notificationId: (state.notificationId ?? 0) + 1,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Filter logic
  // ---------------------------------------------------------------------------

  void _emitFilteredState({
    HomeTab? selectedTab,
    bool? isLoading,
  }) {
    final tab = selectedTab ?? state.selectedTab;
    final filtered = _filterHosts(tab);

    emit(
      state.copyWith(
        selectedTab: tab,
        hosts: filtered,
        isLoading: isLoading,
        favoriteIds: _favoriteIds,
      ),
    );
  }

  List<HostEntity> _filterHosts(HomeTab tab) {
    final all = _allHosts.values.toList();

    switch (tab) {
      case HomeTab.active:
        return all
            .where((h) =>
                h.presence == null ||
                h.presence?.status == 'online' ||
                h.presence?.busy == true ||
                h.presence?.state == 'busy')
            .toList();

      case HomeTab.favorites:
        return _favoriteHosts;

      case HomeTab.offline:
        return all
            .where((h) =>
                h.presence?.status == 'offline' &&
                h.presence?.busy != true &&
                h.presence?.state != 'busy')
            .toList();
    }
  }

  // ---------------------------------------------------------------------------
  // Entity helpers
  // ---------------------------------------------------------------------------

  HostEntity _mergeHostProfile(HostEntity target, HostEntity profile) {
    return HostEntity(
      id: profile.id,
      fullName: profile.fullName.isNotEmpty ? profile.fullName : target.fullName,
      phone: profile.phone.isNotEmpty ? profile.phone : target.phone,
      avatarUrl: profile.avatarUrl.isNotEmpty ? profile.avatarUrl : target.avatarUrl,
      selfieUrl: profile.selfieUrl.isNotEmpty ? profile.selfieUrl : target.selfieUrl,
      dob: profile.dob.isNotEmpty ? profile.dob : target.dob,
      gender: profile.gender.isNotEmpty ? profile.gender : target.gender,
      audioRate: profile.audioRate > 0 ? profile.audioRate : target.audioRate,
      videoRate: profile.videoRate > 0 ? profile.videoRate : target.videoRate,
      isAudioAllowed: profile.isAudioAllowed,
      isVideoAllowed: profile.isVideoAllowed,
      presence: target.presence ?? profile.presence,
    );
  }

  HostEntity _buildPatchedHost(HostEntity host, HostPresenceEntity presence) {
    return host.copyWith(presence: presence);
  }

  /// Builds a stub [HostEntity] from a socket presence-only event.
  /// Profile fields (name, avatar) remain empty until the backend includes
  /// them in the socket payload or a profile API becomes available.
  HostEntity _buildHostFromPresence(HostPresenceEntity presence) {
    return HostEntity(
      id: presence.userId,
      fullName: '',
      phone: '',
      avatarUrl: '',
      selfieUrl: '',
      dob: '',
      gender: '',
      audioRate: 0,
      videoRate: 0,
      isAudioAllowed: presence.audioAvailable,
      isVideoAllowed: presence.videoAvailable,
      presence: presence,
    );
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  Future<void> close() async {
    _snapshotTimer?.cancel();
    await _presenceSub?.cancel();
    _disconnectPresence();
    return super.close();
  }
}
