import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/models/video_call_online_user.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/home_user_entity.dart'; // for UserStatus enum
import 'online_users_state.dart';

@injectable
class OnlineUsersCubit extends Cubit<OnlineUsersState> {
  OnlineUsersCubit()
      : super(OnlineUsersState(
          selectedTab: VideoCallFilterTab.active,
          users: _filterUsers(VideoCallFilterTab.active),
        ));

  void selectTab(VideoCallFilterTab tab) {
    emit(state.copyWith(
      selectedTab: tab,
      users: _filterUsers(tab),
    ));
  }

  static List<VideoCallOnlineUser> _filterUsers(VideoCallFilterTab tab) {
    return VideoCallOnlineUser.sampleUsers.where((user) {
      switch (tab) {
        case VideoCallFilterTab.active:
          return user.status == UserStatus.online ||
              user.status == UserStatus.onCall;
        case VideoCallFilterTab.favorites:
          return user.isFavorite;
        case VideoCallFilterTab.offline:
          return user.status == UserStatus.offline;
      }
    }).toList();
  }
}
