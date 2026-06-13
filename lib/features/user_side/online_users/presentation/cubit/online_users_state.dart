import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/models/video_call_online_user.dart';

enum VideoCallFilterTab { active, favorites, offline }

class OnlineUsersState extends Equatable {
  final VideoCallFilterTab selectedTab;
  final List<VideoCallOnlineUser> users;

  const OnlineUsersState({
    required this.selectedTab,
    required this.users,
  });

  @override
  List<Object?> get props => [selectedTab, users];

  OnlineUsersState copyWith({
    VideoCallFilterTab? selectedTab,
    List<VideoCallOnlineUser>? users,
  }) {
    return OnlineUsersState(
      selectedTab: selectedTab ?? this.selectedTab,
      users: users ?? this.users,
    );
  }
}
