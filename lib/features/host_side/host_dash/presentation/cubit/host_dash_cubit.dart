import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/home_user_entity.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/paginated_hosts_entity.dart';
import 'package:mint_talk/features/user_side/home/domain/usecases/get_hosts_usecase.dart';
import '../../domain/entities/host_dashboard_data_entity.dart';
import '../../domain/entities/host_online_item_entity.dart';
import '../../domain/entities/host_preferences_entity.dart';
import '../../domain/usecases/get_host_dashboard_data_usecase.dart';
import '../../domain/usecases/update_host_preferences_usecase.dart';
import 'host_dash_state.dart';

@injectable
class HostDashCubit extends Cubit<HostDashState> {
  static const int _fallbackAudioRate = 60;
  static const int _fallbackVideoRate = 120;

  static const List<HostOnlineItemEntity> _sampleHosts = [
    HostOnlineItemEntity(
      name: 'Meera',
      imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      status: UserStatus.online,
    ),
    HostOnlineItemEntity(
      name: 'Riya',
      imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      status: UserStatus.onCall,
    ),
    HostOnlineItemEntity(
      name: 'Sneha',
      imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      status: UserStatus.online,
    ),
    HostOnlineItemEntity(
      name: 'Pooja',
      imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
      status: UserStatus.onCall,
    ),
    HostOnlineItemEntity(
      name: 'Anjali',
      imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150',
      status: UserStatus.online,
    ),
    HostOnlineItemEntity(
      name: 'Kavya',
      imageUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=150',
      status: UserStatus.onCall,
    ),
    HostOnlineItemEntity(
      name: 'Nisha',
      imageUrl: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=150',
      status: UserStatus.online,
    ),
    HostOnlineItemEntity(
      name: 'Ishita',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      status: UserStatus.onCall,
    ),
  ];

  final GetHostDashboardDataUseCase getHostDashboardDataUseCase;
  final UpdateHostPreferencesUseCase updateHostPreferencesUseCase;
  final AuthLocalDataSource authLocalDataSource;
  final GetHostsUseCase getHostsUseCase;

  HostDashCubit(
    this.getHostDashboardDataUseCase,
    this.updateHostPreferencesUseCase,
    this.authLocalDataSource,
    this.getHostsUseCase,
  ) : super(const HostDashState());

  Future<void> loadDashboardData() async {
    emit(state.copyWith(status: HostDashStatus.loading, isHostsLoading: true));
    final results = await Future.wait([
      getHostDashboardDataUseCase(NoParams()),
      getHostsUseCase(const GetHostsParams(isOnline: true)),
      getHostsUseCase(const GetHostsParams(isOnline: false)),
    ]);

    final dashboardResult = results[0] as Either<Failure, HostDashboardDataEntity>;
    final onlineHostsResult = results[1] as Either<Failure, PaginatedHostsEntity>;
    final onCallHostsResult = results[2] as Either<Failure, PaginatedHostsEntity>;

    List<HostOnlineItemEntity> fetchedHosts = [];

    onlineHostsResult.fold(
      (failure) {
        debugPrint('❌ [HostDashCubit] getHosts (online) API failed: ${failure.message}');
      },
      (paginatedHosts) {
        debugPrint('✅ [HostDashCubit] getHosts (online) API response success! Total: ${paginatedHosts.total}, Count: ${paginatedHosts.items.length}');
        for (final host in paginatedHosts.items) {
          debugPrint('   👉 Online Host: ${host.fullName}');
          fetchedHosts.add(
            HostOnlineItemEntity(
              name: host.fullName.isNotEmpty ? host.fullName : 'Host',
              imageUrl: host.avatarUrl,
              status: UserStatus.online,
            ),
          );
        }
      },
    );

    onCallHostsResult.fold(
      (failure) {
        debugPrint('❌ [HostDashCubit] getHosts (on-call) API failed: ${failure.message}');
      },
      (paginatedHosts) {
        debugPrint('✅ [HostDashCubit] getHosts (on-call) API response success! Total: ${paginatedHosts.total}, Count: ${paginatedHosts.items.length}');
        for (final host in paginatedHosts.items) {
          debugPrint('   👉 On-Call Host: ${host.fullName}');
          fetchedHosts.add(
            HostOnlineItemEntity(
              name: host.fullName.isNotEmpty ? host.fullName : 'Host',
              imageUrl: host.avatarUrl,
              status: UserStatus.onCall,
            ),
          );
        }
      },
    );

    if (fetchedHosts.isEmpty) {
      debugPrint('ℹ️ [HostDashCubit] No hosts returned from backend endpoints, using fallback sample hosts');
      fetchedHosts = _sampleHosts;
    }

    if (isClosed) return;

    dashboardResult.fold(
      (failure) => emit(
        state.copyWith(
          status: HostDashStatus.failure,
          errorMessage: failure.message,
          onlineHosts: fetchedHosts,
          isHostsLoading: false,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: HostDashStatus.success,
          dashboardData: data,
          onlineHosts: fetchedHosts,
          isHostsLoading: false,
        ),
      ),
    );
  }

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

  Future<void> startReceivingCalls() async {
    if (!state.isAnyCallSelected || state.isStartingCall) {
      return;
    }
    final role = await authLocalDataSource.getRole();
    if (role != 'staff') {
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

    final audioRate =
        await authLocalDataSource.getAudioRate() ?? _fallbackAudioRate;
    final videoRate =
        await authLocalDataSource.getVideoRate() ?? _fallbackVideoRate;
    final preferences = HostPreferencesEntity(
      audioRate: audioRate,
      videoRate: videoRate,
      isAudioAllowed: state.isAudioSelected,
      isVideoAllowed: state.isVideoSelected,
    );
    final result = await updateHostPreferencesUseCase(preferences);
    if (isClosed) return;

    await result.fold<Future<void>>(
      (failure) async {
        emit(
          state.copyWith(
            isStartingCall: false,
            preferenceUpdateStatus: HostPreferenceUpdateStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (updatedPreferences) async {
        await Future.wait([
          authLocalDataSource.saveAudioRate(updatedPreferences.audioRate),
          authLocalDataSource.saveVideoRate(updatedPreferences.videoRate),
          authLocalDataSource.saveIsAudioAllowed(
            updatedPreferences.isAudioAllowed,
          ),
          authLocalDataSource.saveIsVideoAllowed(
            updatedPreferences.isVideoAllowed,
          ),
        ]);
        if (isClosed) return;
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
      },
    );
  }

  void pickupIncomingCall() {
    emit(state.copyWith(callFlowMode: HostDashCallFlowMode.waitingForNextCall));
  }

  void declineIncomingCall() {
    emit(state.copyWith(callFlowMode: HostDashCallFlowMode.waitingForNextCall));
  }

  Future<void> stopWaitingForCalls() async {
    final audioRate =
        await authLocalDataSource.getAudioRate() ?? _fallbackAudioRate;
    final videoRate =
        await authLocalDataSource.getVideoRate() ?? _fallbackVideoRate;

    emit(
      state.copyWith(
        callFlowMode: HostDashCallFlowMode.selecting,
        isAudioSelected: false,
        isVideoSelected: false,
      ),
    );

    await Future.wait([
      authLocalDataSource.saveIsAudioAllowed(false),
      authLocalDataSource.saveIsVideoAllowed(false),
    ]);

    final preferences = HostPreferencesEntity(
      audioRate: audioRate,
      videoRate: videoRate,
      isAudioAllowed: false,
      isVideoAllowed: false,
    );

    final result = await updateHostPreferencesUseCase(preferences);
    result.fold(
      (failure) {
        debugPrint(
          '❌ [HostDashCubit] Failed to update preferences on cancel: ${failure.message}',
        );
      },
      (updatedPreferences) {
        debugPrint(
          '✅ [HostDashCubit] Host preferences updated to offline/canceled (audio: ${updatedPreferences.isAudioAllowed}, video: ${updatedPreferences.isVideoAllowed})',
        );
      },
    );
  }
}

