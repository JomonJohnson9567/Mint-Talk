import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';

/// [all] is only offered on the video-call hosts screen; home shows the rest.
enum HomeTab { active, favorites, offline, all }

/// How [UserGrid] lays out hosts; the audio- and video-call hosts screens
/// offer a toggle, home stays on [grid].
enum HostLayout { grid, list }

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

  /// IDs of the current user's favorited hosts — used to render heart-icon
  /// state on cards across every tab, sourced from the backend.
  final Set<String> favoriteIds;

  /// Logged-in user's full name (local storage) — drives the greeting banner.
  final String? userName;

  /// Case-insensitive name filter applied on top of [selectedTab].
  final String searchQuery;

  final HostLayout layout;

  const HomeState({
    this.selectedTab = HomeTab.active,
    this.hosts = const [],
    this.isLoading = true,
    this.errorMessage,
    this.notificationMessage,
    this.notificationType,
    this.notificationId = 0,
    this.favoriteIds = const {},
    this.userName,
    this.searchQuery = '',
    this.layout = HostLayout.grid,
  });

  HomeState copyWith({
    HomeTab? selectedTab,
    List<HostEntity>? hosts,
    bool? isLoading,
    String? errorMessage,
    String? notificationMessage,
    NotificationType? notificationType,
    int? notificationId,
    Set<String>? favoriteIds,
    String? userName,
    String? searchQuery,
    HostLayout? layout,
  }) {
    return HomeState(
      selectedTab: selectedTab ?? this.selectedTab,
      hosts: hosts ?? this.hosts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      notificationMessage: notificationMessage ?? this.notificationMessage,
      notificationType: notificationType ?? this.notificationType,
      notificationId: notificationId ?? this.notificationId,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      userName: userName ?? this.userName,
      searchQuery: searchQuery ?? this.searchQuery,
      layout: layout ?? this.layout,
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
    favoriteIds,
    userName,
    searchQuery,
    layout,
  ];
}
