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

  const HomeState({
    this.selectedTab = HomeTab.active,
    this.users = const [],
    this.isLoading = false,
    this.notificationMessage,
    this.notificationType,
    this.notificationId = 0,
  });

  HomeState copyWith({
    HomeTab? selectedTab,
    List<HomeUserEntity>? users,
    bool? isLoading,
    String? notificationMessage,
    NotificationType? notificationType,
    int? notificationId,
  }) {
    return HomeState(
      selectedTab: selectedTab ?? this.selectedTab,
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      notificationMessage: notificationMessage ?? this.notificationMessage,
      notificationType: notificationType ?? this.notificationType,
      notificationId: notificationId ?? this.notificationId,
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
  ];
}
