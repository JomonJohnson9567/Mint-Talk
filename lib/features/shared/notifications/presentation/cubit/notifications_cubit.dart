import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/services/session/session_manager.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/shared/notifications/domain/entities/notification_entity.dart';
import 'package:mint_talk/features/shared/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:mint_talk/features/shared/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:mint_talk/features/shared/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:mint_talk/features/shared/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:mint_talk/features/shared/notifications/domain/usecases/watch_new_notifications_usecase.dart';
import 'package:mint_talk/features/shared/notifications/domain/usecases/watch_notification_reconnects_usecase.dart';
import 'notifications_state.dart';

const _kPageLimit = 20;

/// Single, app-wide instance (provided once at the app root, same as
/// `WalletCubit`) so the header bell badge and the notification list screen
/// share one source of truth instead of each fetching independently.
///
/// In-app only (no FCM/APNs): live items arrive via `new_notification`,
/// deduplicated by `_id`; the list is refetched on socket reconnect and app
/// resume to catch anything pushed while offline, and reset on logout.
@injectable
class NotificationsCubit extends Cubit<NotificationsState>
    with WidgetsBindingObserver {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final GetUnreadCountUseCase _getUnreadCountUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase _markAllNotificationsReadUseCase;
  final WatchNewNotificationsUseCase _watchNewNotificationsUseCase;
  final WatchNotificationReconnectsUseCase _watchReconnectsUseCase;
  final SessionManager _sessionManager;

  StreamSubscription<NotificationEntity>? _newNotificationSub;
  StreamSubscription<void>? _reconnectSub;
  StreamSubscription<void>? _logoutSub;
  Future<void>? _refreshInFlight;

  NotificationsCubit(
    this._getNotificationsUseCase,
    this._getUnreadCountUseCase,
    this._markNotificationReadUseCase,
    this._markAllNotificationsReadUseCase,
    this._watchNewNotificationsUseCase,
    this._watchReconnectsUseCase,
    this._sessionManager,
  ) : super(const NotificationsState()) {
    _newNotificationSub = _watchNewNotificationsUseCase().listen(_onNewNotification);
    _reconnectSub = _watchReconnectsUseCase().listen((_) => refresh());
    // The next account must not see this one's notifications; `initial`
    // also makes the nav screens load afresh after the next login.
    _logoutSub = _sessionManager.forcedLogouts.listen((_) {
      if (!isClosed) emit(const NotificationsState());
    });
    WidgetsBinding.instance.addObserver(this);
  }

  /// Background catch-up (reconnect, resume): refetches page 1 and the
  /// unread count without the loading skeleton. No-op until a session has
  /// loaded the list once, so it never fires while logged out.
  Future<void> refresh() {
    if (isClosed ||
        state.status == NotificationsStatus.initial ||
        state.status == NotificationsStatus.loading) {
      return Future.value();
    }
    return _refreshInFlight ??= _refresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<void> _refresh() async {
    final listResult = await _getNotificationsUseCase(
      const GetNotificationsParams(page: 1, limit: _kPageLimit),
    );
    final countResult = await _getUnreadCountUseCase(NoParams());
    if (isClosed || state.status == NotificationsStatus.initial) return;

    listResult.fold((_) {}, (paginated) {
      emit(state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: _dedupe(paginated.items),
        page: paginated.page,
        totalPages: paginated.totalPages,
        unreadCount: countResult.fold((_) => paginated.unreadCount, (count) => count),
      ));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  /// Keeps the first occurrence of each id (ids missing → kept as-is).
  static List<NotificationEntity> _dedupe(Iterable<NotificationEntity> items) {
    final seen = <String>{};
    return [
      for (final item in items)
        if (item.id.isEmpty || seen.add(item.id)) item,
    ];
  }

  Future<void> loadNotifications() async {
    emit(state.copyWith(status: NotificationsStatus.loading));

    final listResult = await _getNotificationsUseCase(
      const GetNotificationsParams(page: 1, limit: _kPageLimit),
    );
    final countResult = await _getUnreadCountUseCase(NoParams());

    listResult.fold(
      (failure) {
        emit(state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (paginated) {
        emit(state.copyWith(
          status: NotificationsStatus.loaded,
          notifications: _dedupe(paginated.items),
          page: paginated.page,
          totalPages: paginated.totalPages,
          unreadCount: countResult.fold((_) => paginated.unreadCount, (count) => count),
        ));
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == NotificationsStatus.loadingMore) return;

    emit(state.copyWith(status: NotificationsStatus.loadingMore));

    final result = await _getNotificationsUseCase(
      GetNotificationsParams(page: state.page + 1, limit: _kPageLimit),
    );

    result.fold(
      (failure) {
        // Keep the already-loaded list visible; just drop back out of the
        // loading-more state so the user can retry by scrolling again.
        emit(state.copyWith(status: NotificationsStatus.loaded));
      },
      (paginated) {
        emit(state.copyWith(
          status: NotificationsStatus.loaded,
          // Live pushes shift the pages, so page N+1 can repeat items.
          notifications: _dedupe([...state.notifications, ...paginated.items]),
          page: paginated.page,
          totalPages: paginated.totalPages,
        ));
      },
    );
  }

  Future<void> markAsRead(String id) async {
    final matches = state.notifications.where((n) => n.id == id);
    if (matches.isEmpty || matches.first.isRead) return;

    _applyLocalRead(id);

    final result = await _markNotificationReadUseCase(NotificationIdParams(id: id));
    result.fold(
      (failure) => _applyLocalUnread(id),
      (_) {},
    );
  }

  Future<void> markAllAsRead() async {
    if (state.unreadCount == 0) return;

    final previous = state.notifications;
    emit(state.copyWith(
      notifications: previous.map((n) => n.copyWith(isRead: true)).toList(),
      unreadCount: 0,
    ));

    final result = await _markAllNotificationsReadUseCase(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(notifications: previous, unreadCount: state.unreadCount)),
      (_) {},
    );
  }

  void _onNewNotification(NotificationEntity notification) {
    if (isClosed) return;
    // The same push can arrive twice (socket redelivery, or already
    // fetched by a reconnect refresh) — count and show it once.
    if (notification.id.isNotEmpty &&
        state.notifications.any((n) => n.id == notification.id)) {
      return;
    }
    emit(state.copyWith(
      notifications: [notification, ...state.notifications],
      unreadCount: state.unreadCount + 1,
    ));
  }

  void _applyLocalRead(String id) {
    emit(state.copyWith(
      notifications: state.notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList(),
      unreadCount: (state.unreadCount - 1).clamp(0, 1 << 30),
    ));
  }

  void _applyLocalUnread(String id) {
    emit(state.copyWith(
      notifications: state.notifications
          .map((n) => n.id == id ? n.copyWith(isRead: false) : n)
          .toList(),
      unreadCount: state.unreadCount + 1,
    ));
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _newNotificationSub?.cancel();
    _reconnectSub?.cancel();
    _logoutSub?.cancel();
    return super.close();
  }
}
