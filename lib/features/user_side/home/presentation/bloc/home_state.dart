import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';

enum HomeTab { active, favorites, offline }

enum NotificationType { info, warning, success, error }

class HomeState extends Equatable {
  final HomeTab selectedTab;

  /// Filtered list of hosts shown in the grid for the current [selectedTab].
  final List<HostEntity> hosts;

  /// True while the socket is connecting and no events have arrived yet.
  final bool isLoading;

  /// Set when a socket connection error occurs.
  final String? errorMessage;

  // ── Notification snack-bar ────────────────────────────────────────────────
  final String? notificationMessage;
  final NotificationType? notificationType;

  /// Incremented on each notification to trigger BlocListener even when the
  /// message text is the same.
  final int? notificationId;

  // ── User call rates (read from local storage) ─────────────────────────────
  final int? audioRate;
  final int? videoRate;

  const HomeState({
    this.selectedTab = HomeTab.active,
    this.hosts = const [],
    this.isLoading = true,
    this.errorMessage,
    this.notificationMessage,
    this.notificationType,
    this.notificationId = 0,
    this.audioRate,
    this.videoRate,
  });

  HomeState copyWith({
    HomeTab? selectedTab,
    List<HostEntity>? hosts,
    bool? isLoading,
    String? errorMessage,
    String? notificationMessage,
    NotificationType? notificationType,
    int? notificationId,
    int? audioRate,
    int? videoRate,
  }) {
    return HomeState(
      selectedTab: selectedTab ?? this.selectedTab,
      hosts: hosts ?? this.hosts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
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
        hosts,
        isLoading,
        errorMessage,
        notificationMessage,
        notificationType,
        notificationId,
        audioRate,
        videoRate,
      ];
}
