import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/features/user_side/home/domain/usecases/get_hosts_usecase.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/models/video_call_online_user.dart';
import 'online_users_state.dart';

@injectable
class OnlineUsersCubit extends Cubit<OnlineUsersState> {
  final GetHostsUseCase? getHostsUseCase;

  OnlineUsersCubit({this.getHostsUseCase})
      : super(const OnlineUsersState(
          selectedTab: VideoCallFilterTab.active,
          users: [],
          isLoading: true,
        )) {
    loadHosts();
  }

  Future<void> loadHosts() async {
    if (getHostsUseCase == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    // Map the selected tab to the correct endpoint:
    // active → /hosts/online, offline → /hosts/on-call (busy)
    final isOnline = state.selectedTab != VideoCallFilterTab.offline;

    final result = await getHostsUseCase!(GetHostsParams(isOnline: isOnline));

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          users: VideoCallOnlineUser.sampleUsers, // Fallback if server is not reachable
        ));
      },
      (paginatedHosts) {
        final mappedUsers = paginatedHosts.items
            .map((host) => VideoCallOnlineUser.fromHostEntity(host))
            .toList();

        emit(state.copyWith(
          isLoading: false,
          users: mappedUsers.isNotEmpty ? mappedUsers : VideoCallOnlineUser.sampleUsers,
        ));
      },
    );
  }

  void selectTab(VideoCallFilterTab tab) {
    emit(state.copyWith(selectedTab: tab));
    loadHosts();
  }
}
