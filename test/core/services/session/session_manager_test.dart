import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/services/incoming_call_alert/i_incoming_call_alert_service.dart';
import 'package:mint_talk/core/services/session/session_manager.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mint_talk/features/shared/block_users/data/blocked_hosts_store.dart';
import 'package:mocktail/mocktail.dart';

class _MockTokenManager extends Mock implements TokenManager {}

class _MockAuthLocalDataSource extends Mock implements IAuthLocalDataSource {}

class _MockPresenceSocketService extends Mock implements IPresenceSocketService {}

class _MockNavigationService extends Mock implements NavigationService {}

class _MockIncomingCallAlertService extends Mock
    implements IIncomingCallAlertService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockTokenManager tokenManager;
  late _MockAuthLocalDataSource localDataSource;
  late _MockPresenceSocketService socketService;
  late _MockNavigationService navigationService;
  late BlockedHostsStore blockedHostsStore;
  late _MockIncomingCallAlertService incomingCallAlertService;
  late SessionManager sessionManager;
  late bool hasRefreshToken;

  setUp(() {
    tokenManager = _MockTokenManager();
    localDataSource = _MockAuthLocalDataSource();
    socketService = _MockPresenceSocketService();
    navigationService = _MockNavigationService();
    blockedHostsStore = BlockedHostsStore();
    incomingCallAlertService = _MockIncomingCallAlertService();
    when(() => incomingCallAlertService.stopHostStandby())
        .thenAnswer((_) async {});
    when(() => incomingCallAlertService.hideIncomingCall())
        .thenAnswer((_) async {});
    hasRefreshToken = true;

    when(() => tokenManager.hasRefreshToken()).thenAnswer((_) async => hasRefreshToken);
    when(() => tokenManager.clearAll()).thenAnswer((_) async => hasRefreshToken = false);
    when(() => localDataSource.clearAuthData()).thenAnswer((_) async {});
    when(() => socketService.disconnect()).thenReturn(null);
    when(() => navigationService.navigateAndRemoveUntil(any()))
        .thenAnswer((_) async => null);

    sessionManager = SessionManager(
      tokenManager,
      localDataSource,
      socketService,
      navigationService,
      blockedHostsStore,
      incomingCallAlertService,
    );
  });

  group('forceLogout', () {
    test('takes an online host out of standby', () async {
      await sessionManager.forceLogout();

      verify(() => incomingCallAlertService.stopHostStandby()).called(1);
      verify(() => incomingCallAlertService.hideIncomingCall()).called(1);
    });

    test('clears blocked hosts so they do not carry over to the next account', () async {
      blockedHostsStore.add('host-1');

      await sessionManager.forceLogout();

      expect(blockedHostsStore.ids, isEmpty);
    });

    test('notifies listeners, disconnects the socket, clears everything, then goes to login', () async {
      var notified = false;
      sessionManager.forcedLogouts.listen((_) => notified = true);

      await sessionManager.forceLogout();
      await pumpEventQueue();

      expect(notified, isTrue);
      verifyInOrder([
        () => socketService.disconnect(),
        () => tokenManager.clearAll(),
        () => localDataSource.clearAuthData(),
        () => navigationService.navigateAndRemoveUntil(AppRoutes.phoneNumber),
      ]);
    });

    test('concurrent triggers (socket push + several 401s) tear down only once', () async {
      await Future.wait([
        sessionManager.forceLogout(message: 'a'),
        sessionManager.forceLogout(message: 'b'),
        sessionManager.forceLogout(message: 'c'),
      ]);

      verify(() => tokenManager.clearAll()).called(1);
      verify(() => navigationService.navigateAndRemoveUntil(any())).called(1);
    });

    test('a straggling 401 after the logout is ignored', () async {
      await sessionManager.forceLogout();
      await sessionManager.forceLogout();

      verify(() => navigationService.navigateAndRemoveUntil(any())).called(1);
    });

    test('runs again once a new login has stored a refresh token', () async {
      await sessionManager.forceLogout();
      hasRefreshToken = true; // user logged back in
      await sessionManager.forceLogout();

      verify(() => navigationService.navigateAndRemoveUntil(any())).called(2);
    });
  });

  group('validateSession', () {
    test('logs out when the refresh is rejected', () async {
      when(() => tokenManager.refreshAccessToken())
          .thenAnswer((_) async => RefreshResult.rejected);

      await sessionManager.validateSession();

      verify(() => navigationService.navigateAndRemoveUntil(AppRoutes.phoneNumber)).called(1);
    });

    test('stays logged in on a transient failure', () async {
      when(() => tokenManager.refreshAccessToken())
          .thenAnswer((_) async => RefreshResult.transientFailure);

      await sessionManager.validateSession();

      verifyNever(() => tokenManager.clearAll());
      verifyNever(() => navigationService.navigateAndRemoveUntil(any()));
    });

    test('does nothing when not logged in', () async {
      hasRefreshToken = false;

      await sessionManager.validateSession();

      verifyNever(() => tokenManager.refreshAccessToken());
    });
  });
}
