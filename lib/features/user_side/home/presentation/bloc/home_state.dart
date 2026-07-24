import 'package:equatable/equatable.dart';
import '../../domain/entities/home_user_entity.dart';

enum HomeTab { active, favorites, offline }

enum NotificationType { info, warning, success, error }

class HomeState extends Equatable {
  final HomeTab selectedTab;
  final List<HomeUserEntity> users;
  final bool isLoading;
  final String? notificationMessage;
  final NotificationType? notificationType;
  final int? notificationId;
  final int? audioRate;
  final int? videoRate;

  const HomeState({
    this.selectedTab = HomeTab.active,
    this.users = const [],
    this.isLoading = false,
    this.notificationMessage,
    this.notificationType,
    this.notificationId = 0,
    this.audioRate,
    this.videoRate,
  });

  HomeState copyWith({
    HomeTab? selectedTab,
    List<HomeUserEntity>? users,
    bool? isLoading,
    String? notificationMessage,
    NotificationType? notificationType,
    int? notificationId,
    int? audioRate,
    int? videoRate,
  }) {
    return HomeState(
      selectedTab: selectedTab ?? this.selectedTab,
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      notificationMessage: notificationMessage ?? this.notificationMessage,
      notificationType: notificationType ?? this.notificationType,
      notificationId: notificationId ?? this.notificationId,
      audioRate: audioRate ?? this.audioRate,
      videoRate: videoRate ?? this.videoRate,
    );
  }

  @override
  List<Object?> get props => [
    selectedTab,
    users,
    isLoading,
    notificationMessage,
    notificationType,
    notificationId,
    audioRate,
    videoRate,
  ];
}
