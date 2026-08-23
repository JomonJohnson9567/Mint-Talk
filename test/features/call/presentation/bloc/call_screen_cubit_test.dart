// Regression safety net for CallScreenCubit's core lifecycle (join → active
// → end). This is real-time, billing-affecting code — these tests exist so
// any future refactor (e.g. extracting the connection-health cluster into
// its own collaborator, as flagged in the architecture audit) has something
// concrete to run against before landing.
import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/config/env/env_config.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/services/agora/i_agora_service.dart';
import 'package:mint_talk/core/services/connectivity/connectivity_service.dart';
import 'package:mint_talk/core/services/permissions/call_permission_service.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_session_entity.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_socket_event.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/call/domain/repositories/i_call_repository.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/accept_call_usecase.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/activate_call_usecase.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/cancel_call_usecase.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/end_call_usecase.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/initiate_call_usecase.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockInitiateCallUseCase extends Mock implements InitiateCallUseCase {}

class _MockAcceptCallUseCase extends Mock implements AcceptCallUseCase {}

class _MockActivateCallUseCase extends Mock implements ActivateCallUseCase {}

class _MockEndCallUseCase extends Mock implements EndCallUseCase {}

class _MockCancelCallUseCase extends Mock implements CancelCallUseCase {}

class _MockAgoraService extends Mock implements IAgoraService {}

class _MockCallRepository extends Mock implements ICallRepository {}

class _MockEnvConfig extends Mock implements EnvConfig {}

class _MockCallPermissionService extends Mock implements ICallPermissionService {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockConnectivityService extends Mock implements IConnectivityService {}

class _MockPresenceSocketService extends Mock implements IPresenceSocketService {}

CallSessionEntity _session({
  String callId = 'call-1',
  String status = 'ringing',
  String? agoraChannel = 'channel-1',
  String? agoraToken = 'token-1',
}) {
  return CallSessionEntity(
    callId: callId,
    agoraChannel: agoraChannel,
    agoraToken: agoraToken,
    status: status,
    callType: CallType.audio,
    duration: 0,
    billedMinutes: 0,
    totalPointsDebited: 0,
    ratePerMinute: 10,
    endReason: '',
    hostId: 'host-1',
    callerId: 'caller-1',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // WakelockPlus.enable()/disable() (called around every call's lifecycle)
  // go through a Pigeon-generated BasicMessageChannel with no real
  // implementation in unit tests. Reply with an encoded `[null]` — Pigeon's
  // success envelope for a void-returning call — so the awaited Future
  // resolves instead of throwing.
  const wakelockChannelName =
      'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle';
  const wakelockCodec = StandardMessageCodec();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
    wakelockChannelName,
    (message) async => wakelockCodec.encodeMessage(<Object?>[null]),
  );

  late _MockInitiateCallUseCase initiateCallUseCase;
  late _MockAcceptCallUseCase acceptCallUseCase;
  late _MockActivateCallUseCase activateCallUseCase;
  late _MockEndCallUseCase endCallUseCase;
  late _MockCancelCallUseCase cancelCallUseCase;
  late _MockAgoraService agoraService;
  late _MockCallRepository callRepository;
  late _MockEnvConfig envConfig;
  late _MockCallPermissionService permissionService;
  late _MockAuthRepository authRepository;
  late _MockConnectivityService connectivityService;
  late _MockPresenceSocketService presenceSocketService;

  late StreamController<AgoraCallEvent> agoraEvents;
  late StreamController<bool> connectivityEvents;
  late StreamController<CallSocketEvent> socketEvents;

  late CallScreenCubit cubit;

  setUpAll(() {
    registerFallbackValue(
      const InitiateCallParams(hostId: 'host-1', callType: CallType.audio),
    );
  });

  setUp(() {
    initiateCallUseCase = _MockInitiateCallUseCase();
    acceptCallUseCase = _MockAcceptCallUseCase();
    activateCallUseCase = _MockActivateCallUseCase();
    endCallUseCase = _MockEndCallUseCase();
    cancelCallUseCase = _MockCancelCallUseCase();
    agoraService = _MockAgoraService();
    callRepository = _MockCallRepository();
    envConfig = _MockEnvConfig();
    permissionService = _MockCallPermissionService();
    authRepository = _MockAuthRepository();
    connectivityService = _MockConnectivityService();
    presenceSocketService = _MockPresenceSocketService();

    agoraEvents = StreamController<AgoraCallEvent>.broadcast();
    connectivityEvents = StreamController<bool>.broadcast();
    socketEvents = StreamController<CallSocketEvent>.broadcast();

    when(() => agoraService.events).thenAnswer((_) => agoraEvents.stream);
    when(() => agoraService.engine).thenReturn(null);
    when(() => agoraService.initialize(any())).thenAnswer((_) async {});
    when(() => agoraService.joinChannel(
          channelName: any(named: 'channelName'),
          rtcToken: any(named: 'rtcToken'),
          userAccount: any(named: 'userAccount'),
          isVideoCall: any(named: 'isVideoCall'),
        )).thenAnswer((_) async {});
    when(() => agoraService.leaveChannel()).thenAnswer((_) async {});
    when(() => agoraService.dispose()).thenAnswer((_) async {});

    when(() => callRepository.callSocketEvents).thenAnswer((_) => socketEvents.stream);
    when(() => callRepository.subscribeCallSocket(any())).thenReturn(null);
    when(() => callRepository.unsubscribeCallSocket(any())).thenReturn(null);

    when(() => envConfig.agoraAppId).thenReturn('0123456789abcdef0123456789abcdef');

    when(() => permissionService.requestPermissions(isVideoCall: any(named: 'isVideoCall')))
        .thenAnswer((_) async => const CallPermissionResult(isGranted: true));

    when(() => authRepository.getUserId()).thenAnswer((_) async => 'caller-1');

    when(() => connectivityService.onStatusChanged).thenAnswer((_) => connectivityEvents.stream);

    when(() => presenceSocketService.requestPresenceSnapshot()).thenReturn(null);

    cubit = CallScreenCubit(
      initiateCallUseCase,
      acceptCallUseCase,
      activateCallUseCase,
      endCallUseCase,
      cancelCallUseCase,
      agoraService,
      callRepository,
      envConfig,
      permissionService,
      authRepository,
      connectivityService,
      presenceSocketService,
    );
  });

  tearDown(() async {
    await cubit.close();
    await agoraEvents.close();
    await connectivityEvents.close();
    await socketEvents.close();
  });

  test('startOutgoingCall joins the Agora channel once initiate succeeds', () async {
    when(() => initiateCallUseCase(any())).thenAnswer((_) async => Right(_session()));

    await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
    // startOutgoingCall kicks off _connectToAgora without awaiting it (so the
    // UI isn't blocked on the join handshake) — pump the microtask queue so
    // that fire-and-forget chain fully settles before asserting on it.
    await pumpEventQueue();

    expect(cubit.state.status, CallScreenStatus.ringing);
    expect(cubit.state.mediaStatus, CallMediaStatus.joining);
    verify(() => callRepository.subscribeCallSocket('call-1')).called(1);
    verify(() => agoraService.joinChannel(
          channelName: 'channel-1',
          rtcToken: 'token-1',
          userAccount: 'caller-1',
          isVideoCall: false,
        )).called(1);
  });

  test('startOutgoingCall surfaces a failed status when initiate fails', () async {
    when(() => initiateCallUseCase(any()))
        .thenAnswer((_) async => const Left(ServerFailure(message: 'no hosts available')));

    await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
    await pumpEventQueue();

    expect(cubit.state.status, CallScreenStatus.failed);
    expect(cubit.state.errorMessage, 'no hosts available');
    verifyNever(() => agoraService.joinChannel(
          channelName: any(named: 'channelName'),
          rtcToken: any(named: 'rtcToken'),
          userAccount: any(named: 'userAccount'),
          isVideoCall: any(named: 'isVideoCall'),
        ));
  });

  test('remote joining Agora activates the call exactly once and starts billing state', () async {
    when(() => initiateCallUseCase(any())).thenAnswer((_) async => Right(_session()));
    when(() => activateCallUseCase(any())).thenAnswer((_) async => Right(_session(status: 'active')));

    await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
    await pumpEventQueue();

    agoraEvents.add(const AgoraLocalJoinSuccess());
    await pumpEventQueue();
    expect(cubit.state.mediaStatus, CallMediaStatus.waitingForRemote);

    agoraEvents.add(const AgoraRemoteUserJoined(42));
    await pumpEventQueue();

    expect(cubit.state.status, CallScreenStatus.active);
    expect(cubit.state.mediaStatus, CallMediaStatus.active);
    expect(cubit.state.remoteUid, 42);
    verify(() => activateCallUseCase('call-1')).called(1);

    // A second remote-joined event (e.g. a benign duplicate callback) must
    // not trigger a second billing-activation call.
    agoraEvents.add(const AgoraRemoteUserJoined(42));
    await pumpEventQueue();
    verifyNever(() => activateCallUseCase('call-1'));
  });

  test(
    'a transient activate failure is retried instead of permanently '
    'abandoning billing for the call',
    () async {
      when(() => initiateCallUseCase(any())).thenAnswer((_) async => Right(_session()));

      var attempt = 0;
      when(() => activateCallUseCase(any())).thenAnswer((_) async {
        attempt++;
        // First attempt fails (e.g. a transient network blip right as both
        // sides join Agora); the retry succeeds.
        if (attempt == 1) {
          return const Left(ServerFailure(message: 'network error'));
        }
        return Right(_session(status: 'active'));
      });

      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();
      agoraEvents.add(const AgoraLocalJoinSuccess());
      agoraEvents.add(const AgoraRemoteUserJoined(42));
      await pumpEventQueue();

      // The failed first attempt must not leave the call stuck: media
      // already looks connected (Agora succeeded) but billing hasn't
      // started yet.
      expect(cubit.state.status, isNot(CallScreenStatus.active));
      expect(attempt, 1);

      // First retry backs off 2s (see _activateRetryAttempts * 2s) — wait
      // past it for the retry timer to fire and the second, successful
      // attempt to resolve.
      await Future<void>.delayed(const Duration(seconds: 2, milliseconds: 300));
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.active);
      expect(attempt, 2);
    },
  );

  test(
    'a pending activate retry is skipped if the peer\'s own activation '
    'already caught the call up via a socket "active" push',
    () async {
      when(() => initiateCallUseCase(any())).thenAnswer((_) async => Right(_session()));

      var attempt = 0;
      when(() => activateCallUseCase(any())).thenAnswer((_) async {
        attempt++;
        return const Left(ServerFailure(message: 'network error'));
      });

      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();
      agoraEvents.add(const AgoraLocalJoinSuccess());
      agoraEvents.add(const AgoraRemoteUserJoined(42));
      await pumpEventQueue();
      expect(attempt, 1);

      // The peer's device activated successfully and the server pushed the
      // authoritative "active" event before our retry timer fired.
      socketEvents.add(const CallSocketEvent(callId: 'call-1', status: 'active', duration: 0));
      await pumpEventQueue();
      expect(cubit.state.status, CallScreenStatus.active);

      // Once the retry timer does fire, it must be a no-op — activation is
      // already confirmed, so retrying would be a redundant HTTP call.
      await Future<void>.delayed(const Duration(seconds: 2, milliseconds: 300));
      await pumpEventQueue();
      expect(attempt, 1);
    },
  );

  test('endCall on an active call invokes the HTTP end usecase exactly once', () async {
    when(() => initiateCallUseCase(any())).thenAnswer((_) async => Right(_session()));
    when(() => activateCallUseCase(any())).thenAnswer((_) async => Right(_session(status: 'active')));
    when(() => endCallUseCase(any())).thenAnswer((_) async => Right(_session(status: 'ended')));

    await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
    await pumpEventQueue();
    agoraEvents.add(const AgoraLocalJoinSuccess());
    agoraEvents.add(const AgoraRemoteUserJoined(42));
    await pumpEventQueue();
    expect(cubit.state.status, CallScreenStatus.active);

    await cubit.endCall();
    expect(cubit.state.status, CallScreenStatus.ended);
    verify(() => endCallUseCase('call-1')).called(1);
    verifyNever(() => cancelCallUseCase(any()));

    // Calling endCall again (e.g. a duplicate tap while the first is still
    // settling) must not fire a second HTTP end request.
    await cubit.endCall();
    verifyNever(() => endCallUseCase('call-1'));
  });

  test('endCall while still ringing cancels instead of ending', () async {
    when(() => initiateCallUseCase(any())).thenAnswer((_) async => Right(_session()));
    when(() => cancelCallUseCase(any())).thenAnswer((_) async => Right(_session(status: 'cancelled')));

    await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
    await pumpEventQueue();
    expect(cubit.state.status, CallScreenStatus.ringing);

    await cubit.endCall();

    expect(cubit.state.status, CallScreenStatus.ended);
    verify(() => cancelCallUseCase('call-1')).called(1);
    verifyNever(() => endCallUseCase(any()));
  });

  test('a server-pushed "ended" socket event terminates the call locally without an extra HTTP call', () async {
    when(() => initiateCallUseCase(any())).thenAnswer((_) async => Right(_session()));
    when(() => activateCallUseCase(any())).thenAnswer((_) async => Right(_session(status: 'active')));

    await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
    await pumpEventQueue();
    agoraEvents.add(const AgoraLocalJoinSuccess());
    agoraEvents.add(const AgoraRemoteUserJoined(42));
    await pumpEventQueue();
    expect(cubit.state.status, CallScreenStatus.active);

    socketEvents.add(const CallSocketEvent(callId: 'call-1', status: 'ended', endReason: 'peer_hangup'));
    await pumpEventQueue();

    expect(cubit.state.status, CallScreenStatus.ended);
    verifyNever(() => endCallUseCase(any()));
    verify(() => agoraService.leaveChannel()).called(1);
  });

  test(
    'a late "ended" socket event after Agora reports the remote offline '
    'clears the reconnecting banner instead of leaving it stuck',
    () async {
      when(() => initiateCallUseCase(any())).thenAnswer((_) async => Right(_session()));
      when(() => activateCallUseCase(any())).thenAnswer((_) async => Right(_session(status: 'active')));

      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();
      agoraEvents.add(const AgoraLocalJoinSuccess());
      agoraEvents.add(const AgoraRemoteUserJoined(42));
      await pumpEventQueue();
      expect(cubit.state.status, CallScreenStatus.active);

      // Agora's offline signal is unreliable — a genuine hangup can still
      // report a non-voluntary reason, which puts the UI into the
      // "reconnecting" banner state while it waits up to 25s for the
      // authoritative server event.
      agoraEvents.add(const AgoraRemoteUserLeft(42, UserOfflineReasonType.userOfflineDropped));
      await pumpEventQueue();
      expect(cubit.state.networkStatus.isRemoteReconnecting, isTrue);

      // The authoritative event lands well within the grace window.
      socketEvents.add(const CallSocketEvent(callId: 'call-1', status: 'ended', endReason: 'peer_hangup'));
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.ended);
      expect(
        cubit.state.networkStatus.isRemoteReconnecting,
        isFalse,
        reason: 'the label must not keep showing "reconnecting" once the call has actually ended',
      );
      verifyNever(() => endCallUseCase(any()));
    },
  );

  test(
    'manually ending the call while waiting on a suspected remote hangup '
    'checks the server instead of firing a redundant /end',
    () async {
      when(() => initiateCallUseCase(any())).thenAnswer((_) async => Right(_session()));
      when(() => activateCallUseCase(any())).thenAnswer((_) async => Right(_session(status: 'active')));
      // The peer's own /end already completed server-side by the time the
      // user gets impatient and taps End Call themselves.
      when(() => callRepository.getCallDetails('call-1'))
          .thenAnswer((_) async => Right(_session(status: 'ended')));

      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();
      agoraEvents.add(const AgoraLocalJoinSuccess());
      agoraEvents.add(const AgoraRemoteUserJoined(42));
      await pumpEventQueue();

      agoraEvents.add(const AgoraRemoteUserLeft(42, UserOfflineReasonType.userOfflineDropped));
      await pumpEventQueue();
      expect(cubit.state.networkStatus.isRemoteReconnecting, isTrue);

      // User taps "End Call" before either the socket event or the 25s
      // local timeout resolves things on their own.
      await cubit.endCall();

      expect(cubit.state.status, CallScreenStatus.ended);
      expect(cubit.state.networkStatus.isRemoteReconnecting, isFalse);
      verify(() => callRepository.getCallDetails('call-1')).called(1);
      // Must NOT fire a second, redundant /end against an already-ended
      // call — that's what was producing a bogus near-zero duration.
      verifyNever(() => endCallUseCase(any()));
    },
  );

  test(
    'manually ending the call falls back to a real /end when the offline '
    'report was just a network blip, not a genuine hangup',
    () async {
      when(() => initiateCallUseCase(any())).thenAnswer((_) async => Right(_session()));
      when(() => activateCallUseCase(any())).thenAnswer((_) async => Right(_session(status: 'active')));
      when(() => callRepository.getCallDetails('call-1'))
          .thenAnswer((_) async => Right(_session(status: 'active')));
      when(() => endCallUseCase(any())).thenAnswer((_) async => Right(_session(status: 'ended')));

      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();
      agoraEvents.add(const AgoraLocalJoinSuccess());
      agoraEvents.add(const AgoraRemoteUserJoined(42));
      await pumpEventQueue();

      agoraEvents.add(const AgoraRemoteUserLeft(42, UserOfflineReasonType.userOfflineDropped));
      await pumpEventQueue();

      await cubit.endCall();

      expect(cubit.state.status, CallScreenStatus.ended);
      verify(() => callRepository.getCallDetails('call-1')).called(1);
      verify(() => endCallUseCase('call-1')).called(1);
    },
  );

  test(
    'ignores a socket event that belongs to a different call instead of '
    'ending the current one',
    () async {
      when(() => initiateCallUseCase(any())).thenAnswer((_) async => Right(_session()));
      when(() => activateCallUseCase(any())).thenAnswer((_) async => Right(_session(status: 'active')));

      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();
      agoraEvents.add(const AgoraLocalJoinSuccess());
      agoraEvents.add(const AgoraRemoteUserJoined(42));
      await pumpEventQueue();
      expect(cubit.state.status, CallScreenStatus.active);

      // A stray "ended" event for an unrelated call — e.g. a delayed push
      // from a previous call, or cross-talk from a quick succeeding call on
      // the shared, app-wide callSocketEvents stream — must not terminate
      // this call.
      socketEvents.add(
        const CallSocketEvent(callId: 'some-other-call', status: 'ended', endReason: 'peer_hangup'),
      );
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.active);
      verifyNever(() => agoraService.leaveChannel());
    },
  );

  test(
    'ending an active call as the host requests a presence snapshot so a '
    'stale "on call" status does not stick around',
    () async {
      when(() => activateCallUseCase(any())).thenAnswer((_) async => Right(_session(status: 'active')));
      when(() => endCallUseCase(any())).thenAnswer((_) async => Right(_session(status: 'ended')));

      await cubit.startIncomingCall(_session(status: 'connecting'));
      await pumpEventQueue();
      agoraEvents.add(const AgoraLocalJoinSuccess());
      agoraEvents.add(const AgoraRemoteUserJoined(42));
      await pumpEventQueue();
      expect(cubit.state.status, CallScreenStatus.active);

      await cubit.endCall();

      verify(() => presenceSocketService.requestPresenceSnapshot()).called(1);
    },
  );

  test(
    'ending an active call as the caller ALSO requests a presence snapshot '
    '— requesting one only refreshes the requesting device\'s own view, so '
    'the caller checking whether the host they just hung up on is free '
    'again needs this on their own device too, not just the host\'s',
    () async {
      when(() => initiateCallUseCase(any())).thenAnswer((_) async => Right(_session()));
      when(() => activateCallUseCase(any())).thenAnswer((_) async => Right(_session(status: 'active')));
      when(() => endCallUseCase(any())).thenAnswer((_) async => Right(_session(status: 'ended')));

      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();
      agoraEvents.add(const AgoraLocalJoinSuccess());
      agoraEvents.add(const AgoraRemoteUserJoined(42));
      await pumpEventQueue();
      expect(cubit.state.status, CallScreenStatus.active);

      await cubit.endCall();

      verify(() => presenceSocketService.requestPresenceSnapshot()).called(1);
    },
  );
}
