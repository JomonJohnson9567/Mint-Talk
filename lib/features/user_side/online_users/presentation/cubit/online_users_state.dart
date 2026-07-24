import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/models/video_call_online_user.dart';

enum VideoCallFilterTab { active, favorites, offline }

class OnlineUsersState extends Equatable {
  final VideoCallFilterTab selectedTab;
  final List<VideoCallOnlineUser> users;
  final bool isLoading;
  final String? errorMessage;

  const OnlineUsersState({
    required this.selectedTab,
    required this.users,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [selectedTab, users, isLoading, errorMessage];

  OnlineUsersState copyWith({
    VideoCallFilterTab? selectedTab,
    List<VideoCallOnlineUser>? users,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OnlineUsersState(
      selectedTab: selectedTab ?? this.selectedTab,
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
