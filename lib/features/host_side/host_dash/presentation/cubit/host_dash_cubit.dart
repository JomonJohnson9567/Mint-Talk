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
import 'package:mint_talk/features/user_side/home/domain/entities/host_presence_entity.dart';
import '../../domain/entities/host_online_item_entity.dart';
import '../../domain/entities/host_preferences_entity.dart';
import '../../domain/usecases/get_host_dashboard_data_usecase.dart';
import 'host_dash_state.dart';

@injectable
class HostDashCubit extends Cubit<HostDashState> {
  static const int _fallbackAudioRate = 60;
  static const int _fallbackVideoRate = 120;

  final GetHostDashboardDataUseCase getHostDashboardDataUseCase;
  final AuthRepository authRepository;
  final IPresenceSocketService presenceSocketService;
  final TokenManager tokenManager;

  /// Tracks all online/on-call hosts seen from the socket, keyed by userId.
  final Map<String, HostOnlineItemEntity> _presenceHostMap = {};

  StreamSubscription<HostPresenceEntity>? _presenceSub;

  HostDashCubit(
    this.getHostDashboardDataUseCase,
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

  void _onPresenceEvent(HostPresenceEntity presence) {
    if (isClosed) return;

    appLogger.d(
      '🟢 [HostDashCubit] Presence event — '
      'userId: ${presence.userId}, status: ${presence.status}, busy: ${presence.busy}',
    );

    if (presence.status == 'offline' && presence.busy != true) {
      // Host went offline — remove from the map
      _presenceHostMap.remove(presence.userId);
    } else {
      // Online or busy — upsert
      _presenceHostMap[presence.userId] = HostOnlineItemEntity(
        name: _presenceHostMap[presence.userId]?.name ?? presence.userId,
        imageUrl: _presenceHostMap[presence.userId]?.imageUrl ?? '',
        status: presence.busy == true ? UserStatus.onCall : UserStatus.online,
      );
    }

    if (!isClosed) {
      emit(state.copyWith(
        onlineHosts: _presenceHostMap.values.toList(),
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
          onlineHosts: _presenceHostMap.values.toList(),
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
    final dashboardResult = await getHostDashboardDataUseCase(NoParams());

    if (isClosed) return;

    dashboardResult.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (data) => emit(
        state.copyWith(
          status: HostDashStatus.success,
          dashboardData: data,
          onlineHosts: _presenceHostMap.values.toList(),
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
