import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/services/session/session_manager.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/shared/notifications/domain/entities/notification_entity.dart';
import 'package:mint_talk/features/shared/notifications/domain/entities/paginated_notifications_entity.dart';
import 'package:mint_talk/features/shared/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:mint_talk/features/shared/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:mint_talk/features/shared/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:mint_talk/features/shared/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:mint_talk/features/shared/notifications/domain/usecases/watch_new_notifications_usecase.dart';
import 'package:mint_talk/features/shared/notifications/domain/usecases/watch_notification_reconnects_usecase.dart';
import 'package:mint_talk/features/shared/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:mint_talk/features/shared/notifications/presentation/cubit/notifications_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetNotifications extends Mock implements GetNotificationsUseCase {}

class _MockGetUnreadCount extends Mock implements GetUnreadCountUseCase {}

class _MockMarkRead extends Mock implements MarkNotificationReadUseCase {}

class _MockMarkAllRead extends Mock
    implements MarkAllNotificationsReadUseCase {}

class _MockWatchNew extends Mock implements WatchNewNotificationsUseCase {}

class _MockWatchReconnects extends Mock
    implements WatchNotificationReconnectsUseCase {}

class _MockSessionManager extends Mock implements SessionManager {}

NotificationEntity _n(String id) => NotificationEntity(
  id: id,
  userId: 'u1',
  title: 'Title $id',
  message: 'Message',
  type: 'withdrawal',
  isRead: false,
  createdAt: DateTime(2026, 11, 10),
);

void main() {
  late _MockGetNotifications getNotifications;
  late _MockGetUnreadCount getUnreadCount;
  late StreamController<NotificationEntity> pushes;
  late StreamController<void> reconnects;
  late StreamController<void> logouts;
  late NotificationsCubit cubit;

  setUpAll(() {
    registerFallbackValue(const GetNotificationsParams());
    registerFallbackValue(NoParams());
  });

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    getNotifications = _MockGetNotifications();
    getUnreadCount = _MockGetUnreadCount();
    pushes = StreamController<NotificationEntity>.broadcast();
    reconnects = StreamController<void>.broadcast();
    logouts = StreamController<void>.broadcast();
    final watchNew = _MockWatchNew();
    final watchReconnects = _MockWatchReconnects();
    final session = _MockSessionManager();
    when(() => watchNew()).thenAnswer((_) => pushes.stream);
    when(() => watchReconnects()).thenAnswer((_) => reconnects.stream);
    when(() => session.forcedLogouts).thenAnswer((_) => logouts.stream);
    when(() => getUnreadCount(any())).thenAnswer((_) async => const Right(1));
    when(() => getNotifications(any())).thenAnswer(
      (_) async => Right(
        PaginatedNotificationsEntity(
          page: 1,
          limit: 20,
          total: 1,
          totalPages: 1,
          unreadCount: 1,
          items: [_n('a')],
        ),
      ),
    );

    cubit = NotificationsCubit(
      getNotifications,
      getUnreadCount,
      _MockMarkRead(),
      _MockMarkAllRead(),
      watchNew,
      watchReconnects,
      session,
    );
  });

  tearDown(() async {
    await cubit.close();
    await pushes.close();
    await reconnects.close();
    await logouts.close();
  });

  test('a push with an id already in the list is ignored', () async {
    await cubit.loadNotifications();
    pushes.add(_n('a'));
    await pumpEventQueue();

    expect(cubit.state.notifications.map((n) => n.id), ['a']);
    expect(cubit.state.unreadCount, 1);

    pushes.add(_n('b'));
    pushes.add(_n('b'));
    await pumpEventQueue();
    expect(cubit.state.notifications.map((n) => n.id), ['b', 'a']);
    expect(cubit.state.unreadCount, 2);
  });

  test('reconnect refetches once loaded, never before', () async {
    reconnects.add(null);
    await pumpEventQueue();
    verifyNever(() => getNotifications(any()));

    await cubit.loadNotifications();
    reconnects.add(null);
    await pumpEventQueue();
    verify(() => getNotifications(any())).called(2);
  });

  test('logout resets to initial so the next account loads afresh', () async {
    await cubit.loadNotifications();
    logouts.add(null);
    await pumpEventQueue();

    expect(cubit.state.status, NotificationsStatus.initial);
    expect(cubit.state.notifications, isEmpty);
  });
}
