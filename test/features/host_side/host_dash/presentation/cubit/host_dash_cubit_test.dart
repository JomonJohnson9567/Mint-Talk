import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/services/incoming_call_alert/i_incoming_call_alert_service.dart';
import 'package:mint_talk/core/services/permissions/call_permission_service.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';
import 'package:mint_talk/features/host_side/host_dash/domain/usecases/get_host_dashboard_data_usecase.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/host_dash_cubit.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/host_dash_state.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_presence_entity.dart';
import 'package:mint_talk/features/user_side/home/domain/usecases/get_hosts_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockPresenceSocketService extends Mock
    implements IPresenceSocketService {}

class _MockGetHostDashboardDataUseCase extends Mock
    implements GetHostDashboardDataUseCase {}

class _MockGetHostsUseCase extends Mock implements GetHostsUseCase {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockTokenManager extends Mock implements TokenManager {}

class _MockIncomingCallAlertService extends Mock
    implements IIncomingCallAlertService {}

class _MockCallPermissionService extends Mock
    implements ICallPermissionService {}

void main() {
  // HostDashCubit registers an AppLifecycleListener.
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockPresenceSocketService socket;
  late _MockAuthRepository auth;
  late _MockTokenManager tokens;
  late _MockGetHostDashboardDataUseCase getDashboard;
  late _MockGetHostsUseCase getHosts;
  late _MockIncomingCallAlertService alerts;
  late _MockCallPermissionService permissions;
  late StreamController<bool> connectionStatus;
  late StreamController<HostPresenceEntity> presence;

  setUpAll(() {
    registerFallbackValue(const GetHostsParams());
    registerFallbackValue(NoParams());
    HostDashCubit.recoveryDelays = const [
      Duration(milliseconds: 20),
      Duration(milliseconds: 20),
      Duration(milliseconds: 20),
    ];
  });

  setUp(() {
    socket = _MockPresenceSocketService();
    auth = _MockAuthRepository();
    tokens = _MockTokenManager();
    getDashboard = _MockGetHostDashboardDataUseCase();
    getHosts = _MockGetHostsUseCase();
    alerts = _MockIncomingCallAlertService();
    permissions = _MockCallPermissionService();
    connectionStatus = StreamController<bool>.broadcast();
    presence = StreamController<HostPresenceEntity>.broadcast();

    when(() => socket.connectionStatus)
        .thenAnswer((_) => connectionStatus.stream);
    when(() => socket.presenceUpdates).thenAnswer((_) => presence.stream);
    when(() => socket.connect(any())).thenReturn(null);
    when(() => socket.isStalled).thenReturn(false);
    when(() => socket.disconnect()).thenReturn(null);
    when(() => socket.requestPresenceSnapshot()).thenReturn(null);
    when(
      () => socket.updateAvailability(
        audioAvailable: any(named: 'audioAvailable'),
        videoAvailable: any(named: 'videoAvailable'),
      ),
    ).thenReturn(null);

    when(() => tokens.getValidAccessToken()).thenAnswer((_) async => 'token');
    when(() => getHosts(any())).thenAnswer(
      (_) async => const Left(ServerFailure(message: 'unused')),
    );

    when(() => auth.getUserId()).thenAnswer((_) async => 'host-1');
    when(() => auth.getFullName()).thenAnswer((_) async => 'Host');
    when(() => auth.getProfileImagePath()).thenAnswer((_) async => '');
    when(() => auth.getRole()).thenAnswer((_) async => 'staff');
    when(() => auth.getAudioRate()).thenAnswer((_) async => 60);
    when(() => auth.getVideoRate()).thenAnswer((_) async => 120);
    when(() => auth.saveAudioRate(any())).thenAnswer((_) async {});
    when(() => auth.saveVideoRate(any())).thenAnswer((_) async {});
    when(() => auth.saveIsAudioAllowed(any())).thenAnswer((_) async {});
    when(() => auth.saveIsVideoAllowed(any())).thenAnswer((_) async {});

    when(() => permissions.ensureNotificationPermission())
        .thenAnswer((_) async => true);
    when(
      () => alerts.startHostStandby(
        audio: any(named: 'audio'),
        video: any(named: 'video'),
      ),
    ).thenAnswer((_) async => true);
    when(() => alerts.stopHostStandby()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await connectionStatus.close();
    await presence.close();
  });

  HostDashCubit buildCubit() => HostDashCubit(
        getDashboard,
        getHosts,
        auth,
        socket,
        tokens,
        alerts,
        permissions,
      );

  test('seeds isSocketConnected from a socket that was already connected',
      () async {
    when(() => socket.isConnected).thenReturn(true);

    final cubit = buildCubit();

    expect(cubit.state.isSocketConnected, isTrue);
    await cubit.close();
  });

  test('going online on an already-connected socket does not wait for a '
      'connectionStatus event and shows no reconnect banner', () async {
    when(() => socket.isConnected).thenReturn(true);
    final cubit = buildCubit();
    cubit.toggleAudioCall(); // defaults: video on, audio off -> both on

    final stopwatch = Stopwatch()..start();
    await cubit.startReceivingCalls();
    stopwatch.stop();

    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
    expect(cubit.state.callFlowMode, HostDashCallFlowMode.waitingForNextCall);
    expect(cubit.state.isSocketConnected, isTrue);
    verify(
      () => socket.updateAvailability(
        audioAvailable: true,
        videoAvailable: true,
      ),
    ).called(1);
    await cubit.close();
  });

  test('Reconnect tap clears a stale banner when the socket is actually live '
      'and re-asserts availability', () async {
    var live = false;
    when(() => socket.isConnected).thenAnswer((_) => live);
    final cubit = buildCubit();
    cubit.toggleAudioCall(); // defaults: video on, audio off -> both on
    await Future<void>.delayed(Duration.zero); // let init's connect() land

    // Socket comes up later without this cubit ever seeing the transition
    // (the stream doesn't replay), so "Ready" falls back after the timeout.
    // Simulate the end state directly: waiting card + stale banner.
    cubit.emit(
      cubit.state.copyWith(
        callFlowMode: HostDashCallFlowMode.waitingForNextCall,
        isSocketConnected: false,
      ),
    );
    live = true;
    clearInteractions(socket);

    await cubit.retryConnection();

    expect(cubit.state.isSocketConnected, isTrue);
    verify(
      () => socket.updateAvailability(
        audioAvailable: true,
        videoAvailable: true,
      ),
    ).called(1);
    verify(() => socket.requestPresenceSnapshot()).called(1);
    verifyNever(() => socket.connect(any()));
    await cubit.close();
  });

  test('Reconnect tap reconnects when the socket really is down', () async {
    when(() => socket.isConnected).thenReturn(false);
    final cubit = buildCubit();
    await Future<void>.delayed(Duration.zero);
    clearInteractions(socket);

    await cubit.retryConnection();

    expect(cubit.state.isSocketConnected, isFalse);
    verify(() => socket.connect('token')).called(1);
    await cubit.close();
  });

  group('auto-recovery while waiting for calls', () {
    const settle = Duration(milliseconds: 200);

    /// Builds a cubit that is online and waiting, on a connected socket,
    /// with interactions cleared so only recovery calls are counted.
    Future<HostDashCubit> waitingCubit({required bool Function() live}) async {
      when(() => socket.isConnected).thenAnswer((_) => live());
      final cubit = buildCubit();
      await cubit.startReceivingCalls();
      expect(cubit.state.callFlowMode, HostDashCallFlowMode.waitingForNextCall);
      clearInteractions(socket);
      return cubit;
    }

    test('server-closed socket (stalled) is reconnected automatically, at '
        'most recoveryDelays.length times', () async {
      var live = true;
      final cubit = await waitingCubit(live: () => live);

      live = false;
      when(() => socket.isStalled).thenReturn(true);
      connectionStatus.add(false);
      await Future<void>.delayed(settle);

      expect(cubit.state.isSocketConnected, isFalse);
      verify(() => socket.connect('token')).called(3);
      await cubit.close();
    });

    test('recovery stops and availability is re-asserted once the socket '
        'comes back', () async {
      var live = true;
      final cubit = await waitingCubit(live: () => live);

      live = false;
      when(() => socket.isStalled).thenReturn(true);
      when(() => socket.connect(any())).thenAnswer((_) {
        // First reconnect attempt succeeds.
        live = true;
        connectionStatus.add(true);
      });
      connectionStatus.add(false);
      await Future<void>.delayed(settle);

      expect(cubit.state.isSocketConnected, isTrue);
      verify(() => socket.connect('token')).called(1);
      verify(
        () => socket.updateAvailability(
          audioAvailable: false,
          videoAvailable: true,
        ),
      ).called(1);
      await cubit.close();
    });

    test('a transport drop the Manager is already retrying spends no '
        'reconnect attempts', () async {
      var live = true;
      final cubit = await waitingCubit(live: () => live);

      live = false;
      when(() => socket.isStalled).thenReturn(false);
      connectionStatus.add(false);
      await Future<void>.delayed(settle);

      verifyNever(() => socket.connect(any()));
      await cubit.close();
    });

    test('no auto-reconnect after the host taps Stop waiting', () async {
      var live = true;
      final cubit = await waitingCubit(live: () => live);

      await cubit.stopWaitingForCalls();
      live = false;
      when(() => socket.isStalled).thenReturn(true);
      connectionStatus.add(false);
      await Future<void>.delayed(settle);

      verifyNever(() => socket.connect(any()));
      await cubit.close();
    });

    test('no auto-reconnect while still selecting (not online)', () async {
      when(() => socket.isConnected).thenReturn(true);
      final cubit = buildCubit();
      await Future<void>.delayed(Duration.zero);
      clearInteractions(socket);

      when(() => socket.isConnected).thenReturn(false);
      when(() => socket.isStalled).thenReturn(true);
      connectionStatus.add(false);
      await Future<void>.delayed(settle);

      verifyNever(() => socket.connect(any()));
      await cubit.close();
    });

    test('going online while the socket is stalled starts recovery even '
        'though no new disconnect event arrives', () async {
      HostDashCubit.recoveryDelays = const [Duration(milliseconds: 20)];
      addTearDown(
        () => HostDashCubit.recoveryDelays = const [
          Duration(milliseconds: 20),
          Duration(milliseconds: 20),
          Duration(milliseconds: 20),
        ],
      );
      when(() => socket.isConnected).thenReturn(false);
      when(() => socket.isStalled).thenReturn(true);
      final cubit = buildCubit();
      await Future<void>.delayed(Duration.zero); // init's connect()
      clearInteractions(socket);

      // The socket never connects, so startReceivingCalls sits out its 6 s
      // bounded handshake wait before switching to "waiting".
      unawaited(cubit.startReceivingCalls());
      await Future<void>.delayed(const Duration(seconds: 7));

      expect(cubit.state.callFlowMode, HostDashCallFlowMode.waitingForNextCall);
      expect(cubit.state.isSocketConnected, isFalse);
      // One from startReceivingCalls itself, one from the recovery loop.
      verify(() => socket.connect('token')).called(2);
      await cubit.close();
    }, timeout: const Timeout(Duration(seconds: 20)));

    test('app resume while waiting and disconnected reconnects with a '
        'fresh attempt budget', () async {
      var live = true;
      final cubit = await waitingCubit(live: () => live);

      // Exhaust the budget during a long background stretch.
      live = false;
      when(() => socket.isStalled).thenReturn(true);
      connectionStatus.add(false);
      await Future<void>.delayed(settle);
      verify(() => socket.connect('token')).called(3);

      cubit.onAppResumed();
      await Future<void>.delayed(settle);
      verify(() => socket.connect('token')).called(3);
      await cubit.close();
    });

    test('app resume on a socket that is actually live just clears the '
        'banner', () async {
      var live = true;
      final cubit = await waitingCubit(live: () => live);
      cubit.emit(cubit.state.copyWith(isSocketConnected: false));
      clearInteractions(socket);

      cubit.onAppResumed();

      expect(cubit.state.isSocketConnected, isTrue);
      verifyNever(() => socket.connect(any()));
      await cubit.close();
    });
  });
}
