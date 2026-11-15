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
import 'package:mint_talk/core/services/agora/call_audio_route.dart';
import 'package:mint_talk/core/services/agora/i_agora_service.dart';
import 'package:mint_talk/core/services/audio/ringback_tone_service.dart';
import 'package:mint_talk/core/services/call_background/i_call_background_service.dart';
import 'package:mint_talk/core/services/connectivity/connectivity_service.dart';
import 'package:mint_talk/core/services/device_audio/device_audio_models.dart';
import 'package:mint_talk/core/services/device_audio/i_device_audio_service.dart';
import 'package:mint_talk/core/services/permissions/call_permission_service.dart';
import 'package:mint_talk/core/services/proximity/i_proximity_service.dart';
import 'package:mint_talk/core/services/session/session_manager.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/core/utils/server_clock.dart';
import 'package:mint_talk/features/user_side/call/data/models/incoming_call_payload_dto.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_presence_entity.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_session_entity.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_socket_event.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_token_entity.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/call/domain/repositories/i_call_repository.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/accept_call_usecase.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/activate_call_usecase.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/cancel_call_usecase.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/end_call_usecase.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/get_call_token_usecase.dart';
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

class _MockCallPermissionService extends Mock
    implements ICallPermissionService {}

class _MockGetCallTokenUseCase extends Mock implements GetCallTokenUseCase {}

class _MockConnectivityService extends Mock implements IConnectivityService {}

class _MockPresenceSocketService extends Mock
    implements IPresenceSocketService {}

class _MockSessionManager extends Mock implements SessionManager {}

/// Device sound mode / audio devices pushed by the test.
class _FakeDeviceAudioService implements IDeviceAudioService {
  final soundModes = StreamController<DeviceSoundMode>.broadcast();
  final devices = StreamController<AudioOutputDevices>.broadcast();

  @override
  Stream<DeviceSoundMode> get soundModeStream => soundModes.stream;

  @override
  Future<DeviceSoundMode> currentSoundMode() async => DeviceSoundMode.unknown;

  @override
  Stream<AudioOutputDevices> get outputDevicesStream => devices.stream;

  @override
  Future<void> startVibration() async {}

  @override
  Future<void> stopVibration() async {}

  @override
  Stream<void> get volumeKeyPresses => const Stream.empty();

  Future<void> close() async {
    await soundModes.close();
    await devices.close();
  }
}

/// Tracks whether the waiting tone is currently playing.
class _FakeRingbackToneService implements IRingbackToneService {
  bool isPlaying = false;
  int startCount = 0;

  @override
  Future<void> start() async {
    if (!isPlaying) startCount++;
    isPlaying = true;
  }

  @override
  Future<void> stop() async => isPlaying = false;
}

/// Tracks whether the screen-off-at-the-ear sensor is currently on.
class _FakeProximityService implements IProximityService {
  bool enabled = false;

  @override
  Future<void> setEnabled(bool enabled) async => this.enabled = enabled;
}

/// Unsupported platform → the cubit's background sync is a no-op, so the
/// lifecycle tests below behave exactly as before.
class _FakeCallBackgroundService implements ICallBackgroundService {
  final actionController = StreamController<CallBackgroundAction>.broadcast();

  @override
  bool get isSupported => false;

  @override
  Stream<CallBackgroundAction> get actions => actionController.stream;

  @override
  Stream<bool> get pipModeChanges => const Stream.empty();

  @override
  Future<void> hideOngoingCall() async {}

  @override
  Future<void> setPipEnabled(bool enabled) async {}

  @override
  Future<bool> showOngoingCall(OngoingCallInfo info) async => false;
}

HostPresenceEntity _hostPresence({
  String userId = 'host-1',
  bool busy = false,
  String state = 'video_available',
  String status = 'online',
}) {
  return HostPresenceEntity(
    userId: userId,
    role: 'staff',
    status: status,
    lastSeen: 0,
    updatedAt: 0,
    busy: busy,
    audioAvailable: true,
    videoAvailable: true,
    state: state,
  );
}

CallSessionEntity _session({
  String callId = 'call-1',
  String status = 'ringing',
  String? agoraChannel = 'channel-1',
  String? agoraToken = 'token-1',
  int? agoraUid,
  int? connectionTimeoutSeconds,
  int? tokenExpiresInSeconds,
  DateTime? activeAt,
  String endReason = '',
}) {
  return CallSessionEntity(
    callId: callId,
    agoraChannel: agoraChannel,
    agoraToken: agoraToken,
    status: status,
    callType: CallType.audio,
    duration: 0,
    billedUnits: 0,
    totalPointsDebited: 0,
    ratePerMinute: 10,
    endReason: endReason,
    hostId: 'host-1',
    callerId: 'caller-1',
    agoraUid: agoraUid,
    connectionTimeoutSeconds: connectionTimeoutSeconds,
    tokenExpiresInSeconds: tokenExpiresInSeconds,
    activeAt: activeAt,
  );
}

const _callerToken = CallTokenEntity(
  token: 'caller-token',
  channelName: 'channel-1',
  uid: 1,
  expiresInSeconds: 3600,
);

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
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(
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
  late _MockGetCallTokenUseCase getCallTokenUseCase;
  late _MockConnectivityService connectivityService;
  late _MockPresenceSocketService presenceSocketService;

  late _FakeRingbackToneService ringbackTone;
  late _FakeDeviceAudioService deviceAudio;
  late _FakeProximityService proximity;
  late _FakeCallBackgroundService callBackground;
  late ServerClock serverClock;
  late StreamController<AgoraCallEvent> agoraEvents;
  late StreamController<bool> connectivityEvents;
  late StreamController<CallSocketEvent> socketEvents;
  late StreamController<bool> socketConnection;
  late StreamController<HostPresenceEntity> presenceEvents;
  late StreamController<void> forcedLogouts;

  late CallScreenCubit cubit;

  setUpAll(() {
    registerFallbackValue(
      const InitiateCallParams(hostId: 'host-1', callType: CallType.audio),
    );
    registerFallbackValue(CallAudioRoute.earpiece);
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
    getCallTokenUseCase = _MockGetCallTokenUseCase();
    connectivityService = _MockConnectivityService();
    presenceSocketService = _MockPresenceSocketService();
    ringbackTone = _FakeRingbackToneService();
    deviceAudio = _FakeDeviceAudioService();
    proximity = _FakeProximityService();
    callBackground = _FakeCallBackgroundService();
    // Unsynced → falls back to the device clock, so tests that build
    // activeAt from DateTime.now() behave exactly as before.
    serverClock = ServerClock();

    agoraEvents = StreamController<AgoraCallEvent>.broadcast();
    connectivityEvents = StreamController<bool>.broadcast();
    socketEvents = StreamController<CallSocketEvent>.broadcast();
    socketConnection = StreamController<bool>.broadcast();
    presenceEvents = StreamController<HostPresenceEntity>.broadcast();

    when(() => agoraService.events).thenAnswer((_) => agoraEvents.stream);
    when(() => agoraService.engine).thenReturn(null);
    when(() => agoraService.initialize(any())).thenAnswer((_) async {});
    when(
      () => agoraService.joinChannel(
        channelName: any(named: 'channelName'),
        rtcToken: any(named: 'rtcToken'),
        uid: any(named: 'uid'),
        isVideoCall: any(named: 'isVideoCall'),
      ),
    ).thenAnswer((_) async {});
    when(() => agoraService.renewToken(any())).thenAnswer((_) async {});
    when(() => agoraService.leaveChannel()).thenAnswer((_) async {});
    when(() => agoraService.dispose()).thenAnswer((_) async {});
    when(() => agoraService.setAudioRoute(any())).thenAnswer((_) async {});

    when(
      () => callRepository.callSocketEvents,
    ).thenAnswer((_) => socketEvents.stream);
    when(() => callRepository.subscribeCallSocket(any())).thenReturn(null);
    when(() => callRepository.unsubscribeCallSocket(any())).thenReturn(null);

    when(
      () => envConfig.agoraAppId,
    ).thenReturn('0123456789abcdef0123456789abcdef');

    when(
      () => permissionService.requestPermissions(
        isVideoCall: any(named: 'isVideoCall'),
      ),
    ).thenAnswer((_) async => const CallPermissionResult(isGranted: true));

    when(
      () => getCallTokenUseCase(any()),
    ).thenAnswer((_) async => const Right(_callerToken));
    when(
      () => endCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session(status: 'ended')));

    when(
      () => connectivityService.onStatusChanged,
    ).thenAnswer((_) => connectivityEvents.stream);

    when(
      () => presenceSocketService.requestPresenceSnapshot(),
    ).thenReturn(null);
    when(
      () => presenceSocketService.connectionStatus,
    ).thenAnswer((_) => socketConnection.stream);
    when(
      () => presenceSocketService.presenceUpdates,
    ).thenAnswer((_) => presenceEvents.stream);

    forcedLogouts = StreamController<void>.broadcast();
    final sessionManager = _MockSessionManager();
    when(
      () => sessionManager.forcedLogouts,
    ).thenAnswer((_) => forcedLogouts.stream);

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
      connectivityService,
      presenceSocketService,
      getCallTokenUseCase,
      ringbackTone,
      deviceAudio,
      sessionManager,
      serverClock,
      proximity,
      callBackground,
    );
  });

  tearDown(() async {
    CallScreenCubit.noAnswerTimeout = const Duration(seconds: 20);
    CallScreenCubit.connectionTimeoutBackstopMargin = const Duration(
      seconds: 15,
    );
    CallScreenCubit.peerQuitVerifyDelay = const Duration(seconds: 3);
    await cubit.close();
    await agoraEvents.close();
    await connectivityEvents.close();
    await socketEvents.close();
    await socketConnection.close();
    await presenceEvents.close();
    await forcedLogouts.close();
    await deviceAudio.close();
    await callBackground.actionController.close();
  });

  /// Local join + publish (the /activate gate) plus the peer's join/audio
  /// from [peerUid].
  void confirmMedia({int peerUid = 2}) {
    agoraEvents.add(const AgoraLocalJoinSuccess());
    agoraEvents.add(const AgoraLocalAudioPublished());
    agoraEvents.add(AgoraRemoteUserJoined(peerUid));
    agoraEvents.add(AgoraRemoteAudioReceived(peerUid));
  }

  /// Caller: initiate (credentials for uid 1) → ringing → host accepts →
  /// join with the initiate credentials.
  Future<void> startAcceptedOutgoingCall() async {
    when(() => initiateCallUseCase(any())).thenAnswer(
      (_) async => Right(_session(agoraToken: 'caller-token', agoraUid: 1)),
    );
    await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
    await pumpEventQueue();
    socketEvents.add(
      const CallSocketEvent(callId: 'call-1', status: 'accepted'),
    );
    await pumpEventQueue();
  }

  /// Caller call taken all the way to `active`.
  Future<void> startActiveOutgoingCall() async {
    when(
      () => activateCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session(status: 'active')));
    await startAcceptedOutgoingCall();
    confirmMedia();
    await pumpEventQueue();
  }

  test(
    'a forced logout mid-call drops media and returns to idle without /end or a summary',
    () async {
      await startActiveOutgoingCall();
      expect(cubit.state.status, CallScreenStatus.active);

      forcedLogouts.add(null);
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.initial);
      verify(() => agoraService.dispose()).called(greaterThanOrEqualTo(1));
      verify(() => callRepository.unsubscribeCallSocket('call-1')).called(1);
      verifyNever(() => endCallUseCase(any()));
    },
  );

  test('a forced logout with no call in progress is a no-op', () async {
    final emitted = <CallScreenState>[];
    final sub = cubit.stream.listen(emitted.add);

    forcedLogouts.add(null);
    await pumpEventQueue();

    expect(emitted, isEmpty);
    await sub.cancel();
  });

  group('notification / picture-in-picture actions', () {
    test('hang up ends the active call once, even if tapped twice', () async {
      await startActiveOutgoingCall();

      callBackground.actionController
        ..add(CallBackgroundAction.hangUp)
        ..add(CallBackgroundAction.hangUp);
      await pumpEventQueue();

      expect(cubit.state.isCallEnded, isTrue);
      verify(() => endCallUseCase(any())).called(1);
    });

    test('mute toggles the microphone', () async {
      when(() => agoraService.toggleMuteAudio(any())).thenAnswer((_) async {});
      await startActiveOutgoingCall();

      callBackground.actionController.add(CallBackgroundAction.toggleMute);
      await pumpEventQueue();

      expect(cubit.state.isMuted, isTrue);
    });

    test('camera action is ignored on an audio call', () async {
      await startActiveOutgoingCall();

      callBackground.actionController.add(CallBackgroundAction.toggleCamera);
      await pumpEventQueue();

      expect(cubit.state.isVideoMuted, isFalse);
      verifyNever(() => agoraService.toggleMuteVideo(any()));
    });

    test('actions with no call in progress are ignored', () async {
      final emitted = <CallScreenState>[];
      final sub = cubit.stream.listen(emitted.add);

      callBackground.actionController
        ..add(CallBackgroundAction.hangUp)
        ..add(CallBackgroundAction.toggleMute);
      await pumpEventQueue();

      expect(emitted, isEmpty);
      verifyNever(() => endCallUseCase(any()));
      await sub.cancel();
    });
  });

  group('no-answer ring limit', () {
    const shortLimit = Duration(milliseconds: 50);
    const pastLimit = Duration(milliseconds: 120);

    setUp(() {
      CallScreenCubit.noAnswerTimeout = shortLimit;
      when(
        () => initiateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session()));
      when(
        () => cancelCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'cancelled')));
    });

    test(
      'still ringing at the limit → cancels and shows "No answer"',
      () async {
        await cubit.startOutgoingCall(
          hostId: 'host-1',
          callType: CallType.audio,
        );
        await pumpEventQueue();
        expect(cubit.state.status, CallScreenStatus.ringing);
        expect(ringbackTone.isPlaying, isTrue);

        await Future<void>.delayed(pastLimit);
        await pumpEventQueue();

        expect(cubit.state.status, CallScreenStatus.ended);
        expect(cubit.state.isNoAnswer, isTrue);
        expect(ringbackTone.isPlaying, isFalse);
        verify(() => cancelCallUseCase('call-1')).called(1);
        verifyNever(() => endCallUseCase(any()));
      },
    );

    test('host accepts before the limit → nothing is cancelled', () async {
      await startAcceptedOutgoingCall();
      expect(cubit.state.status, CallScreenStatus.connecting);

      await Future<void>.delayed(pastLimit);
      await pumpEventQueue();

      expect(cubit.state.status, isNot(CallScreenStatus.ended));
      verifyNever(() => cancelCallUseCase(any()));
    });

    test('caller hangs up before the limit → exactly one /cancel', () async {
      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();

      await cubit.endCall();
      await Future<void>.delayed(pastLimit);
      await pumpEventQueue();

      expect(cubit.state.isNoAnswer, isFalse);
      verify(() => cancelCallUseCase('call-1')).called(1);
    });

    test('a server "missed" push also reads as "No answer"', () async {
      CallScreenCubit.noAnswerTimeout = const Duration(seconds: 20);
      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();

      socketEvents.add(
        const CallSocketEvent(callId: 'call-1', status: 'missed'),
      );
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.ended);
      expect(cubit.state.isNoAnswer, isTrue);
      verifyNever(() => cancelCallUseCase(any()));
    });
  });

  group('ringback tone', () {
    test('plays while ringing and keeps playing through connecting', () async {
      await startAcceptedOutgoingCall();
      expect(cubit.state.status, CallScreenStatus.connecting);
      expect(ringbackTone.isPlaying, isTrue);
      expect(ringbackTone.startCount, 1);
    });

    test('stops once the call goes active', () async {
      await startActiveOutgoingCall();
      expect(cubit.state.status, CallScreenStatus.active);
      expect(ringbackTone.isPlaying, isFalse);
    });

    test('stops when the caller cancels while ringing', () async {
      when(
        () => initiateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session()));
      when(
        () => cancelCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'cancelled')));
      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();
      expect(ringbackTone.isPlaying, isTrue);

      await cubit.endCall();
      expect(ringbackTone.isPlaying, isFalse);
    });

    test('stops when the host rejects', () async {
      when(
        () => initiateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session()));
      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();

      socketEvents.add(
        const CallSocketEvent(callId: 'call-1', status: 'rejected'),
      );
      await pumpEventQueue();
      expect(ringbackTone.isPlaying, isFalse);
    });

    test('never plays when initiate fails', () async {
      when(
        () => initiateCallUseCase(any()),
      ).thenAnswer((_) async => const Left(ServerFailure(message: 'boom')));
      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();
      expect(ringbackTone.startCount, 0);
    });

    test('never plays on the host side', () async {
      await cubit.startIncomingCall(_session(status: 'accepted'));
      await pumpEventQueue();
      expect(cubit.state.status, CallScreenStatus.connecting);
      expect(ringbackTone.startCount, 0);
    });
  });

  test(
    'startOutgoingCall rings without joining Agora before the host accepts',
    () async {
      when(
        () => initiateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session()));

      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.ringing);
      verify(() => callRepository.subscribeCallSocket('call-1')).called(1);
      verifyNever(() => getCallTokenUseCase(any()));
      verifyNever(
        () => agoraService.joinChannel(
          channelName: any(named: 'channelName'),
          rtcToken: any(named: 'rtcToken'),
          uid: any(named: 'uid'),
          isVideoCall: any(named: 'isVideoCall'),
        ),
      );
    },
  );

  test(
    'caller joins as uid 1 with the initiate credentials, without /token',
    () async {
      await startAcceptedOutgoingCall();

      expect(cubit.state.status, CallScreenStatus.connecting);
      verifyNever(() => getCallTokenUseCase(any()));
      verify(
        () => agoraService.joinChannel(
          channelName: 'channel-1',
          rtcToken: 'caller-token',
          uid: 1,
          isVideoCall: false,
        ),
      ).called(1);
    },
  );

  test('caller falls back to /token when initiate carried no token', () async {
    when(
      () => initiateCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session(agoraToken: null)));
    await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
    await pumpEventQueue();
    socketEvents.add(
      const CallSocketEvent(callId: 'call-1', status: 'accepted'),
    );
    await pumpEventQueue();

    verify(() => getCallTokenUseCase('call-1')).called(1);
    verify(
      () => agoraService.joinChannel(
        channelName: 'channel-1',
        rtcToken: 'caller-token',
        uid: 1,
        isVideoCall: false,
      ),
    ).called(1);
  });

  test('socket events never overwrite the Agora credentials', () async {
    await startAcceptedOutgoingCall();

    socketEvents.add(
      const CallSocketEvent(
        callId: 'call-1',
        status: 'accepted',
        agoraToken: 'host-token',
        agoraChannel: 'other-channel',
      ),
    );
    await pumpEventQueue();

    expect(cubit.state.session?.agoraToken, 'caller-token');
    expect(cubit.state.session?.agoraChannel, 'channel-1');
  });

  test('host joins as uid 2 with the token from the accept response', () async {
    await cubit.startIncomingCall(_session(status: 'accepted'));
    await pumpEventQueue();

    verifyNever(() => getCallTokenUseCase(any()));
    verify(
      () => agoraService.joinChannel(
        channelName: 'channel-1',
        rtcToken: 'token-1',
        uid: 2,
        isVideoCall: false,
      ),
    ).called(1);
  });

  test(
    'host falls back to /token when the accept response has no token',
    () async {
      when(() => getCallTokenUseCase(any())).thenAnswer(
        (_) async => const Right(
          CallTokenEntity(
            token: 'host-token',
            channelName: 'channel-1',
            uid: 2,
          ),
        ),
      );

      await cubit.startIncomingCall(
        _session(status: 'accepted', agoraToken: null),
      );
      await pumpEventQueue();

      verify(() => getCallTokenUseCase('call-1')).called(1);
      verify(
        () => agoraService.joinChannel(
          channelName: 'channel-1',
          rtcToken: 'host-token',
          uid: 2,
          isVideoCall: false,
        ),
      ).called(1);
    },
  );

  test(
    'startOutgoingCall surfaces a failed status when initiate fails',
    () async {
      when(() => initiateCallUseCase(any())).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'no hosts available')),
      );

      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.failed);
      expect(cubit.state.errorMessage, 'no hosts available');
      verifyNever(
        () => agoraService.joinChannel(
          channelName: any(named: 'channelName'),
          rtcToken: any(named: 'rtcToken'),
          uid: any(named: 'uid'),
          isVideoCall: any(named: 'isVideoCall'),
        ),
      );
    },
  );

  test(
    'activates once local join + publish are confirmed, without waiting for the peer',
    () async {
      when(
        () => activateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'accepted')));
      await startAcceptedOutgoingCall();

      agoraEvents.add(const AgoraLocalJoinSuccess());
      await pumpEventQueue();
      verifyNever(() => activateCallUseCase(any()));

      agoraEvents.add(const AgoraLocalAudioPublished());
      await pumpEventQueue();
      verify(() => activateCallUseCase('call-1')).called(1);
      expect(cubit.state.status, CallScreenStatus.connecting);
      expect(cubit.state.isAwaitingPeerActivation, isTrue);
    },
  );

  test(
    'activate "active" starts billing exactly once, ignoring duplicates',
    () async {
      await startActiveOutgoingCall();

      expect(cubit.state.status, CallScreenStatus.active);
      expect(cubit.state.remoteUid, 2);
      verify(() => activateCallUseCase('call-1')).called(1);

      // A duplicate remote-joined callback or a late call_active push must
      // not trigger a second activation or restart billing state.
      agoraEvents.add(const AgoraRemoteUserJoined(2));
      agoraEvents.add(const AgoraRemoteAudioReceived(2));
      socketEvents.add(
        const CallSocketEvent(callId: 'call-1', status: 'active'),
      );
      await pumpEventQueue();
      verifyNever(() => activateCallUseCase('call-1'));
      expect(cubit.state.status, CallScreenStatus.active);
    },
  );

  test(
    'activate "accepted" waits for call_active before billing starts',
    () async {
      when(
        () => activateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'accepted')));
      await startAcceptedOutgoingCall();
      confirmMedia();
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.connecting);
      expect(cubit.state.isAwaitingPeerActivation, isTrue);
      expect(cubit.state.durationSeconds, 0);

      socketEvents.add(
        const CallSocketEvent(callId: 'call-1', status: 'active'),
      );
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.active);
      expect(cubit.state.isAwaitingPeerActivation, isFalse);
      verify(() => activateCallUseCase('call-1')).called(1);
    },
  );

  test('after "accepted" the call is re-read via GET /calls/:id, not re-POSTed '
      'to /activate, and a lost call_active is caught up', () async {
    when(
      () => activateCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session(status: 'accepted')));
    when(
      () => callRepository.getCallDetails('call-1'),
    ).thenAnswer((_) async => Right(_session(status: 'active')));
    await startAcceptedOutgoingCall();
    confirmMedia();
    await pumpEventQueue();
    expect(cubit.state.status, CallScreenStatus.connecting);

    // Lost call_active push: the 5s poll catches it up.
    await Future<void>.delayed(const Duration(seconds: 5, milliseconds: 300));
    await pumpEventQueue();
    expect(cubit.state.status, CallScreenStatus.active);
    verify(() => activateCallUseCase('call-1')).called(1);
    verify(
      () => callRepository.getCallDetails('call-1'),
    ).called(greaterThanOrEqualTo(1));
  });

  test(
    'server connection_timeout ("failed") cleans up locally without /end',
    () async {
      when(
        () => activateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'accepted')));
      await cubit.startIncomingCall(_session(status: 'accepted'));
      await pumpEventQueue();
      confirmMedia(peerUid: 1);
      await pumpEventQueue();

      socketEvents.add(
        const CallSocketEvent(
          callId: 'call-1',
          status: 'failed',
          endReason: 'connection_timeout',
        ),
      );
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.failed);
      expect(cubit.state.errorMessage, couldNotConnectMessage);
      expect(cubit.state.session?.endReason, 'connection_timeout');
      verifyNever(() => endCallUseCase(any()));
      verifyNever(() => cancelCallUseCase(any()));
      verify(() => agoraService.leaveChannel()).called(greaterThanOrEqualTo(1));

      // A repeat of the same push is harmless.
      socketEvents.add(
        const CallSocketEvent(callId: 'call-1', status: 'failed'),
      );
      await pumpEventQueue();
      verifyNever(() => endCallUseCase(any()));
    },
  );

  test(
    'an "ended" push with endReason connection_timeout is also a failed connect',
    () async {
      await cubit.startIncomingCall(_session(status: 'accepted'));
      await pumpEventQueue();

      socketEvents.add(
        const CallSocketEvent(
          callId: 'call-1',
          status: 'ended',
          endReason: 'connection_timeout',
        ),
      );
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.failed);
      expect(cubit.state.errorMessage, couldNotConnectMessage);
      verifyNever(() => endCallUseCase(any()));
    },
  );

  test(
    'the client no longer ends an unconnected call on its own timer',
    () async {
      await cubit.startIncomingCall(
        _session(status: 'accepted', connectionTimeoutSeconds: 1),
      );
      await pumpEventQueue();
      agoraEvents.add(const AgoraLocalJoinSuccess());
      await pumpEventQueue();

      // Well past the server's 1s timeout but before the backstop margin:
      // the server decides, not the client.
      await Future<void>.delayed(const Duration(seconds: 2));
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.connecting);
      verifyNever(() => endCallUseCase(any()));
    },
  );

  test('backstop sends /end once when the server still reports the call as '
      'accepted past its own timeout', () async {
    CallScreenCubit.connectionTimeoutBackstopMargin = Duration.zero;
    when(
      () => callRepository.getCallDetails('call-1'),
    ).thenAnswer((_) async => Right(_session(status: 'accepted')));
    await cubit.startIncomingCall(
      _session(status: 'accepted', connectionTimeoutSeconds: 1),
    );
    await pumpEventQueue();

    await Future<void>.delayed(const Duration(seconds: 1, milliseconds: 300));
    await pumpEventQueue();

    expect(cubit.state.status, CallScreenStatus.failed);
    expect(cubit.state.errorMessage, couldNotConnectMessage);
    verify(() => endCallUseCase('call-1')).called(1);
  });

  test(
    'backstop sends no /end when the server already failed the call',
    () async {
      CallScreenCubit.connectionTimeoutBackstopMargin = Duration.zero;
      when(() => callRepository.getCallDetails('call-1')).thenAnswer(
        (_) async =>
            Right(_session(status: 'failed', endReason: 'connection_timeout')),
      );
      await cubit.startIncomingCall(
        _session(status: 'accepted', connectionTimeoutSeconds: 1),
      );
      await pumpEventQueue();

      await Future<void>.delayed(const Duration(seconds: 1, milliseconds: 300));
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.failed);
      verifyNever(() => endCallUseCase(any()));
    },
  );

  test(
    'backstop cleans up locally only when the server is unreachable',
    () async {
      CallScreenCubit.connectionTimeoutBackstopMargin = Duration.zero;
      when(
        () => callRepository.getCallDetails('call-1'),
      ).thenAnswer((_) async => const Left(NetworkFailure(message: 'offline')));
      await cubit.startIncomingCall(
        _session(status: 'accepted', connectionTimeoutSeconds: 1),
      );
      await pumpEventQueue();

      await Future<void>.delayed(const Duration(seconds: 1, milliseconds: 300));
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.failed);
      verifyNever(() => endCallUseCase(any()));
    },
  );

  test(
    'peer quit: /end is sent if the server still reports the call active',
    () async {
      CallScreenCubit.peerQuitVerifyDelay = Duration.zero;
      await startActiveOutgoingCall();
      when(
        () => callRepository.getCallDetails('call-1'),
      ).thenAnswer((_) async => Right(_session(status: 'active')));

      agoraEvents.add(
        const AgoraRemoteUserLeft(2, UserOfflineReasonType.userOfflineQuit),
      );
      await pumpEventQueue();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.ended);
      verify(() => endCallUseCase('call-1')).called(1);
    },
  );

  test('peer quit: no /end when the server already ended the call', () async {
    CallScreenCubit.peerQuitVerifyDelay = Duration.zero;
    await startActiveOutgoingCall();
    when(
      () => callRepository.getCallDetails('call-1'),
    ).thenAnswer((_) async => Right(_session(status: 'ended')));

    agoraEvents.add(
      const AgoraRemoteUserLeft(2, UserOfflineReasonType.userOfflineQuit),
    );
    await pumpEventQueue();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await pumpEventQueue();

    expect(cubit.state.status, CallScreenStatus.ended);
    verify(() => callRepository.getCallDetails('call-1')).called(1);
    verifyNever(() => endCallUseCase(any()));
  });

  test('a late activate response after the call ended is ignored', () async {
    final pending = Completer<Either<Failure, CallSessionEntity>>();
    when(() => activateCallUseCase(any())).thenAnswer((_) => pending.future);
    await startAcceptedOutgoingCall();
    confirmMedia();
    await pumpEventQueue();

    socketEvents.add(const CallSocketEvent(callId: 'call-1', status: 'ended'));
    await pumpEventQueue();
    expect(cubit.state.status, CallScreenStatus.ended);

    pending.complete(Right(_session(status: 'active')));
    await pumpEventQueue();
    expect(cubit.state.status, CallScreenStatus.ended);
    expect(cubit.state.durationSeconds, 0);
  });

  test(
    'a 4xx activate failure does not loop while the server still says accepted',
    () async {
      when(() => activateCallUseCase(any())).thenAnswer(
        (_) async =>
            const Left(ServerFailure(message: 'bad request', statusCode: 400)),
      );
      when(
        () => callRepository.getCallDetails('call-1'),
      ).thenAnswer((_) async => Right(_session(status: 'accepted')));
      await startAcceptedOutgoingCall();
      confirmMedia();
      await pumpEventQueue();

      verify(() => activateCallUseCase('call-1')).called(1);
      verify(() => callRepository.getCallDetails('call-1')).called(1);
      expect(cubit.state.status, CallScreenStatus.connecting);
      verifyNever(() => endCallUseCase(any()));
    },
  );

  test(
    'a 4xx activate failure is not retried; the call is reconciled instead',
    () async {
      when(() => activateCallUseCase(any())).thenAnswer(
        (_) async => const Left(
          ServerFailure(message: 'call not accepted', statusCode: 409),
        ),
      );
      when(() => callRepository.getCallDetails('call-1')).thenAnswer(
        (_) async =>
            Right(_session(status: 'failed', endReason: 'connection_timeout')),
      );
      await startAcceptedOutgoingCall();
      confirmMedia();
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.failed);
      verify(() => activateCallUseCase('call-1')).called(1);
      verifyNever(() => endCallUseCase(any()));
    },
  );

  test(
    'local media failure ends the call via /end and never activates',
    () async {
      when(
        () => activateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'active')));
      await startAcceptedOutgoingCall();

      agoraEvents.add(const AgoraLocalJoinSuccess());
      agoraEvents.add(const AgoraLocalMediaFailed('Microphone failed'));
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.failed);
      verify(() => endCallUseCase('call-1')).called(1);
      verifyNever(() => activateCallUseCase(any()));
    },
  );

  test('an Agora join exception ends the accepted call via /end', () async {
    when(
      () => agoraService.joinChannel(
        channelName: any(named: 'channelName'),
        rtcToken: any(named: 'rtcToken'),
        uid: any(named: 'uid'),
        isVideoCall: any(named: 'isVideoCall'),
      ),
    ).thenThrow(const AgoraJoinException('boom'));

    await cubit.startIncomingCall(_session(status: 'accepted'));
    await pumpEventQueue();

    expect(cubit.state.status, CallScreenStatus.failed);
    verify(() => endCallUseCase('call-1')).called(1);
    verify(() => agoraService.dispose()).called(greaterThanOrEqualTo(1));
  });

  test('token is renewed via /token before it expires', () async {
    when(() => getCallTokenUseCase(any())).thenAnswer(
      (_) async => const Right(
        CallTokenEntity(token: 'renewed', channelName: 'channel-1', uid: 2),
      ),
    );

    // 2s lifetime → renewal scheduled at the halfway point (1s).
    await cubit.startIncomingCall(
      _session(status: 'accepted', tokenExpiresInSeconds: 2),
    );
    await pumpEventQueue();
    verifyNever(() => agoraService.renewToken(any()));

    await Future<void>.delayed(const Duration(seconds: 1, milliseconds: 300));
    await pumpEventQueue();

    verify(() => getCallTokenUseCase('call-1')).called(1);
    verify(() => agoraService.renewToken('renewed')).called(1);
    expect(cubit.state.session?.agoraToken, 'renewed');
  });

  test(
    'the duration counts from the server activeAt, not from acceptance',
    () async {
      final activeAt = DateTime.now().subtract(const Duration(seconds: 42));
      when(
        () => activateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'accepted')));
      await startAcceptedOutgoingCall();
      confirmMedia();
      await pumpEventQueue();

      socketEvents.add(
        CallSocketEvent(callId: 'call-1', status: 'active', activeAt: activeAt),
      );
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.active);
      expect(cubit.state.durationSeconds, inInclusiveRange(42, 43));
    },
  );

  test('a repeated active event corrects a locally-assumed activeAt', () async {
    // The /activate "active" response carries no activeAt → local fallback.
    await startActiveOutgoingCall();
    expect(cubit.state.durationSeconds, 0);

    final activeAt = DateTime.now().subtract(const Duration(seconds: 10));
    socketEvents.add(
      CallSocketEvent(callId: 'call-1', status: 'active', activeAt: activeAt),
    );
    await pumpEventQueue();

    expect(cubit.state.status, CallScreenStatus.active);
    expect(cubit.state.durationSeconds, inInclusiveRange(10, 11));
    verify(() => activateCallUseCase('call-1')).called(1);
  });

  test(
    'the duration is measured on the server clock, not a skewed device clock',
    () async {
      // Device clock 90 s fast: the server's "now" is 90 s behind DateTime.now().
      final t = serverClock.monotonicNow;
      serverClock.observe(
        serverDate: DateTime.now().subtract(const Duration(seconds: 90)),
        sentAt: t,
        receivedAt: t,
      );
      // The call just went active, by the server's clock.
      final activeAt = serverClock.now();
      when(() => activateCallUseCase(any())).thenAnswer(
        (_) async => Right(_session(status: 'active', activeAt: activeAt)),
      );

      await startAcceptedOutgoingCall();
      confirmMedia();
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.active);
      // Device-clock arithmetic would have shown ~90 s here.
      expect(cubit.state.durationSeconds, inInclusiveRange(0, 1));
    },
  );

  test(
    'the timer never ticks backwards when the server clock re-anchors earlier',
    () async {
      final activeAt = DateTime.now().subtract(const Duration(seconds: 5));
      when(() => activateCallUseCase(any())).thenAnswer(
        (_) async => Right(_session(status: 'active', activeAt: activeAt)),
      );
      await startAcceptedOutgoingCall();
      confirmMedia();
      await pumpEventQueue();
      expect(cubit.state.durationSeconds, inInclusiveRange(5, 6));

      // First sync puts the server clock ~2.5 s behind the device clock.
      final t = serverClock.monotonicNow;
      serverClock.observe(
        serverDate: DateTime.now().subtract(const Duration(seconds: 3)),
        sentAt: t,
        receivedAt: t,
      );

      await Future<void>.delayed(const Duration(milliseconds: 1200));
      expect(cubit.state.durationSeconds, greaterThanOrEqualTo(5));
    },
  );

  group('server releases the host without a call_ended push', () {
    test('ends the call locally when the server confirms it ended', () async {
      await startActiveOutgoingCall();
      expect(cubit.state.status, CallScreenStatus.active);
      when(
        () => callRepository.getCallDetails('call-1'),
      ).thenAnswer((_) async => Right(_session(status: 'ended')));

      presenceEvents.add(_hostPresence());
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.ended);
      verify(() => callRepository.getCallDetails('call-1')).called(1);
      verify(() => agoraService.leaveChannel()).called(greaterThanOrEqualTo(1));
      verifyNever(() => endCallUseCase(any()));
    });

    test(
      'keeps the call running when the server still reports it active',
      () async {
        await startActiveOutgoingCall();
        when(
          () => callRepository.getCallDetails('call-1'),
        ).thenAnswer((_) async => Right(_session(status: 'active')));

        presenceEvents.add(_hostPresence());
        await pumpEventQueue();

        expect(cubit.state.status, CallScreenStatus.active);
        verify(() => callRepository.getCallDetails('call-1')).called(1);
      },
    );

    test('ignores other hosts and a host that is still busy', () async {
      await startActiveOutgoingCall();
      when(
        () => callRepository.getCallDetails('call-1'),
      ).thenAnswer((_) async => Right(_session(status: 'ended')));

      presenceEvents
        ..add(_hostPresence(userId: 'someone-else'))
        ..add(_hostPresence(busy: true, state: 'busy'));
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.active);
      verifyNever(() => callRepository.getCallDetails(any()));
    });

    test('a burst of presence events triggers a single re-read', () async {
      await startActiveOutgoingCall();
      final details = Completer<Either<Failure, CallSessionEntity>>();
      when(
        () => callRepository.getCallDetails('call-1'),
      ).thenAnswer((_) => details.future);

      presenceEvents
        ..add(_hostPresence())
        ..add(_hostPresence())
        ..add(_hostPresence());
      await pumpEventQueue();
      details.complete(Right(_session(status: 'ended')));
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.ended);
      verify(() => callRepository.getCallDetails('call-1')).called(1);
    });

    test('does nothing before the call is active or after it ended', () async {
      await startAcceptedOutgoingCall(); // accepted, not yet active
      presenceEvents.add(_hostPresence());
      await pumpEventQueue();
      verifyNever(() => callRepository.getCallDetails(any()));

      when(
        () => activateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'active')));
      confirmMedia();
      await pumpEventQueue();
      expect(cubit.state.status, CallScreenStatus.active);
      await cubit.endCall();
      await pumpEventQueue();

      presenceEvents.add(_hostPresence());
      await pumpEventQueue();
      verifyNever(() => callRepository.getCallDetails(any()));
    });

    test(
      'host side: works when /accept returned no hostId (taken from the payload)',
      () async {
        when(() => acceptCallUseCase(any())).thenAnswer(
          (_) async => Right(
            _session(status: 'accepted').copyWith(hostId: '', callerId: ''),
          ),
        );
        when(
          () => activateCallUseCase(any()),
        ).thenAnswer((_) async => Right(_session(status: 'active')));
        when(
          () => callRepository.getCallDetails('call-1'),
        ).thenAnswer((_) async => Right(_session(status: 'ended')));

        await cubit.acceptIncomingCall(
          const IncomingCallPayloadDto(
            callId: 'call-1',
            callerId: 'caller-1',
            callerName: 'Caller',
            hostId: 'host-1',
            callType: CallType.audio,
          ),
        );
        await pumpEventQueue();
        confirmMedia(peerUid: 1);
        await pumpEventQueue();
        expect(cubit.state.status, CallScreenStatus.active);
        expect(cubit.state.session?.hostId, 'host-1');

        presenceEvents.add(_hostPresence());
        await pumpEventQueue();

        expect(cubit.state.status, CallScreenStatus.ended);
        verifyNever(() => endCallUseCase(any()));
      },
    );
  });

  test(
    'call_insufficient_balance ends the call locally without /end',
    () async {
      await startActiveOutgoingCall();

      socketEvents.add(
        const CallSocketEvent(callId: 'call-1', status: 'insufficient_balance'),
      );
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.insufficientBalance);
      verifyNever(() => endCallUseCase(any()));
    },
  );

  test('token renewal keeps the call and its timer running', () async {
    final activeAt = DateTime.now().subtract(const Duration(seconds: 5));
    when(() => activateCallUseCase(any())).thenAnswer(
      (_) async => Right(_session(status: 'active', activeAt: activeAt)),
    );
    when(() => getCallTokenUseCase(any())).thenAnswer(
      (_) async => const Right(
        CallTokenEntity(token: 'renewed', channelName: 'channel-1', uid: 1),
      ),
    );
    await startAcceptedOutgoingCall();
    confirmMedia();
    await pumpEventQueue();
    expect(cubit.state.status, CallScreenStatus.active);

    agoraEvents.add(const AgoraTokenWillExpire());
    await pumpEventQueue();

    verify(() => agoraService.renewToken('renewed')).called(1);
    expect(cubit.state.status, CallScreenStatus.active);
    expect(cubit.state.durationSeconds, greaterThanOrEqualTo(5));
    verify(
      () => agoraService.joinChannel(
        channelName: any(named: 'channelName'),
        rtcToken: any(named: 'rtcToken'),
        uid: any(named: 'uid'),
        isVideoCall: any(named: 'isVideoCall'),
      ),
    ).called(1);
  });

  test(
    'socket reconnect reconciles a call the server ended while disconnected',
    () async {
      await startActiveOutgoingCall();
      when(
        () => callRepository.getCallDetails('call-1'),
      ).thenAnswer((_) async => Right(_session(status: 'ended')));

      socketConnection.add(false);
      socketConnection.add(true);
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.ended);
      verifyNever(() => endCallUseCase(any()));
    },
  );

  test(
    'socket reconnect catches a caller up on a missed accepted push',
    () async {
      when(
        () => initiateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(agoraToken: null)));
      when(() => callRepository.getCallDetails('call-1')).thenAnswer(
        (_) async => Right(_session(status: 'accepted', agoraToken: null)),
      );
      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();

      socketConnection.add(true);
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.connecting);
      verify(() => getCallTokenUseCase('call-1')).called(1);
    },
  );

  test('a transient activate failure is retried instead of permanently '
      'abandoning billing for the call', () async {
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

    await startAcceptedOutgoingCall();
    confirmMedia();
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
  });

  test('a pending activate retry is skipped if the peer\'s own activation '
      'already caught the call up via a socket "active" push', () async {
    var attempt = 0;
    when(() => activateCallUseCase(any())).thenAnswer((_) async {
      attempt++;
      return const Left(ServerFailure(message: 'network error'));
    });

    await startAcceptedOutgoingCall();
    confirmMedia();
    await pumpEventQueue();
    expect(attempt, 1);

    // The peer's device activated successfully and the server pushed the
    // authoritative "active" event before our retry timer fired.
    socketEvents.add(
      const CallSocketEvent(callId: 'call-1', status: 'active', duration: 0),
    );
    await pumpEventQueue();
    expect(cubit.state.status, CallScreenStatus.active);

    // Once the retry timer does fire, it must be a no-op — activation is
    // already confirmed, so retrying would be a redundant HTTP call.
    await Future<void>.delayed(const Duration(seconds: 2, milliseconds: 300));
    await pumpEventQueue();
    expect(attempt, 1);
  });

  test(
    'endCall on an active call invokes the HTTP end usecase exactly once',
    () async {
      when(
        () => initiateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session()));
      when(
        () => activateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'active')));
      when(
        () => endCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'ended')));

      await startAcceptedOutgoingCall();
      confirmMedia();
      await pumpEventQueue();
      expect(cubit.state.status, CallScreenStatus.active);

      // The `ended` status must be immediate — the HTTP /end call below is
      // now fire-and-forget, reconciled with the server in the background.
      await cubit.endCall();
      expect(cubit.state.status, CallScreenStatus.ended);
      await pumpEventQueue();
      verify(() => endCallUseCase('call-1')).called(1);
      verifyNever(() => cancelCallUseCase(any()));

      // Calling endCall again (e.g. a duplicate tap while the first is still
      // settling) must not fire a second HTTP end request.
      await cubit.endCall();
      verifyNever(() => endCallUseCase('call-1'));
    },
  );

  test(
    'endCall retries once after a failed /end attempt and still reaches ended',
    () async {
      when(
        () => initiateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session()));
      when(
        () => activateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'active')));

      var callCount = 0;
      when(() => endCallUseCase(any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return const Left(ServerFailure(message: 'timeout'));
        }
        return Right(_session(status: 'ended'));
      });

      await startAcceptedOutgoingCall();
      confirmMedia();
      await pumpEventQueue();
      expect(cubit.state.status, CallScreenStatus.active);

      // `ended` is emitted immediately, before the HTTP retry below even
      // starts — the retry is a background server reconciliation now, not
      // something the call-ending transition waits on.
      await cubit.endCall();
      expect(cubit.state.status, CallScreenStatus.ended);

      // The retry backs off 1s (see _endCallWithRetry's retryDelay) — wait
      // past it for the second, successful attempt to fire.
      await Future<void>.delayed(const Duration(seconds: 1, milliseconds: 300));
      await pumpEventQueue();

      verify(() => endCallUseCase('call-1')).called(2);
      verify(() => agoraService.leaveChannel()).called(greaterThanOrEqualTo(1));
    },
  );

  test(
    'endCall reaches ended (not stuck) even when every /end attempt fails',
    () async {
      when(
        () => initiateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session()));
      when(
        () => activateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'active')));
      when(() => endCallUseCase(any())).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'network down')),
      );

      await startAcceptedOutgoingCall();
      confirmMedia();
      await pumpEventQueue();
      expect(cubit.state.status, CallScreenStatus.active);

      // Even with the backend unreachable on every attempt, the call must
      // still end locally right away — nothing about the ended transition
      // depends on the billing call being confirmed.
      await cubit.endCall();
      expect(cubit.state.status, CallScreenStatus.ended);

      await Future<void>.delayed(const Duration(seconds: 1, milliseconds: 300));
      await pumpEventQueue();

      verify(() => endCallUseCase('call-1')).called(2);
      verify(() => agoraService.leaveChannel()).called(greaterThanOrEqualTo(1));
    },
  );

  test('endCall while still ringing cancels instead of ending', () async {
    when(
      () => initiateCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session()));
    when(
      () => cancelCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session(status: 'cancelled')));

    await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
    await pumpEventQueue();
    expect(cubit.state.status, CallScreenStatus.ringing);

    await cubit.endCall();
    expect(cubit.state.status, CallScreenStatus.ended);

    await pumpEventQueue();
    verify(() => cancelCallUseCase('call-1')).called(1);
    verifyNever(() => endCallUseCase(any()));
  });

  test(
    'a server-pushed "ended" socket event terminates the call locally without an extra HTTP call',
    () async {
      when(
        () => initiateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session()));
      when(
        () => activateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'active')));

      await startAcceptedOutgoingCall();
      confirmMedia();
      await pumpEventQueue();
      expect(cubit.state.status, CallScreenStatus.active);

      socketEvents.add(
        const CallSocketEvent(
          callId: 'call-1',
          status: 'ended',
          endReason: 'peer_hangup',
        ),
      );
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.ended);
      verifyNever(() => endCallUseCase(any()));
      verify(() => agoraService.leaveChannel()).called(1);
    },
  );

  test('a late "ended" socket event after Agora reports the remote offline '
      'clears the reconnecting banner instead of leaving it stuck', () async {
    when(
      () => initiateCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session()));
    when(
      () => activateCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session(status: 'active')));

    await startAcceptedOutgoingCall();
    confirmMedia();
    await pumpEventQueue();
    expect(cubit.state.status, CallScreenStatus.active);

    // Agora's offline signal is unreliable — a genuine hangup can still
    // report a non-voluntary reason, which puts the UI into the
    // "reconnecting" banner state while it waits up to 25s for the
    // authoritative server event.
    agoraEvents.add(
      const AgoraRemoteUserLeft(2, UserOfflineReasonType.userOfflineDropped),
    );
    await pumpEventQueue();
    expect(cubit.state.networkStatus.isRemoteReconnecting, isTrue);

    // The authoritative event lands well within the grace window.
    socketEvents.add(
      const CallSocketEvent(
        callId: 'call-1',
        status: 'ended',
        endReason: 'peer_hangup',
      ),
    );
    await pumpEventQueue();

    expect(cubit.state.status, CallScreenStatus.ended);
    expect(
      cubit.state.networkStatus.isRemoteReconnecting,
      isFalse,
      reason:
          'the label must not keep showing "reconnecting" once the call has actually ended',
    );
    verifyNever(() => endCallUseCase(any()));
  });

  test('manually ending the call while waiting on a suspected remote hangup '
      'checks the server instead of firing a redundant /end', () async {
    when(
      () => initiateCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session()));
    when(
      () => activateCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session(status: 'active')));
    // The peer's own /end already completed server-side by the time the
    // user gets impatient and taps End Call themselves.
    when(
      () => callRepository.getCallDetails('call-1'),
    ).thenAnswer((_) async => Right(_session(status: 'ended')));

    await startAcceptedOutgoingCall();
    confirmMedia();
    await pumpEventQueue();

    agoraEvents.add(
      const AgoraRemoteUserLeft(2, UserOfflineReasonType.userOfflineDropped),
    );
    await pumpEventQueue();
    expect(cubit.state.networkStatus.isRemoteReconnecting, isTrue);

    // User taps "End Call" before either the socket event or the 25s
    // local timeout resolves things on their own.
    await cubit.endCall();
    expect(cubit.state.status, CallScreenStatus.ended);
    expect(cubit.state.networkStatus.isRemoteReconnecting, isFalse);

    await pumpEventQueue();
    verify(() => callRepository.getCallDetails('call-1')).called(1);
    // Must NOT fire a second, redundant /end against an already-ended
    // call — that's what was producing a bogus near-zero duration.
    verifyNever(() => endCallUseCase(any()));
  });

  test('manually ending the call falls back to a real /end when the offline '
      'report was just a network blip, not a genuine hangup', () async {
    when(
      () => initiateCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session()));
    when(
      () => activateCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session(status: 'active')));
    when(
      () => callRepository.getCallDetails('call-1'),
    ).thenAnswer((_) async => Right(_session(status: 'active')));
    when(
      () => endCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session(status: 'ended')));

    await startAcceptedOutgoingCall();
    confirmMedia();
    await pumpEventQueue();

    agoraEvents.add(
      const AgoraRemoteUserLeft(2, UserOfflineReasonType.userOfflineDropped),
    );
    await pumpEventQueue();

    await cubit.endCall();
    expect(cubit.state.status, CallScreenStatus.ended);

    await pumpEventQueue();
    verify(() => callRepository.getCallDetails('call-1')).called(1);
    verify(() => endCallUseCase('call-1')).called(1);
  });

  test('ignores a socket event that belongs to a different call instead of '
      'ending the current one', () async {
    when(
      () => initiateCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session()));
    when(
      () => activateCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session(status: 'active')));

    await startAcceptedOutgoingCall();
    confirmMedia();
    await pumpEventQueue();
    expect(cubit.state.status, CallScreenStatus.active);

    // A stray "ended" event for an unrelated call — e.g. a delayed push
    // from a previous call, or cross-talk from a quick succeeding call on
    // the shared, app-wide callSocketEvents stream — must not terminate
    // this call.
    socketEvents.add(
      const CallSocketEvent(
        callId: 'some-other-call',
        status: 'ended',
        endReason: 'peer_hangup',
      ),
    );
    await pumpEventQueue();

    expect(cubit.state.status, CallScreenStatus.active);
    verifyNever(() => agoraService.leaveChannel());
  });

  test('ending an active call as the host requests a presence snapshot so a '
      'stale "on call" status does not stick around', () async {
    when(
      () => activateCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session(status: 'active')));
    when(
      () => endCallUseCase(any()),
    ).thenAnswer((_) async => Right(_session(status: 'ended')));

    await cubit.startIncomingCall(_session(status: 'accepted'));
    await pumpEventQueue();
    confirmMedia(peerUid: 1);
    await pumpEventQueue();
    expect(cubit.state.status, CallScreenStatus.active);

    await cubit.endCall();

    verify(() => presenceSocketService.requestPresenceSnapshot()).called(1);
  });

  test(
    'ending an active call as the caller ALSO requests a presence snapshot '
    '— requesting one only refreshes the requesting device\'s own view, so '
    'the caller checking whether the host they just hung up on is free '
    'again needs this on their own device too, not just the host\'s',
    () async {
      when(
        () => initiateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session()));
      when(
        () => activateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'active')));
      when(
        () => endCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'ended')));

      await startAcceptedOutgoingCall();
      confirmMedia();
      await pumpEventQueue();
      expect(cubit.state.status, CallScreenStatus.active);

      await cubit.endCall();

      verify(() => presenceSocketService.requestPresenceSnapshot()).called(1);
    },
  );

  group('audio route & device audio', () {
    test(
      'an audio call starts on the earpiece and follows engine route events',
      () async {
        await startAcceptedOutgoingCall();
        expect(cubit.state.audio.route, CallAudioRoute.earpiece);

        agoraEvents.add(const AgoraAudioRouteChanged(CallAudioRoute.speaker));
        await pumpEventQueue();

        expect(cubit.state.audio.route, CallAudioRoute.speaker);
        expect(cubit.state.isSpeakerOn, isTrue);
      },
    );

    test(
      'toggleSpeakerphone switches earpiece ↔ speaker without Bluetooth',
      () async {
        await startAcceptedOutgoingCall();

        cubit.toggleSpeakerphone();
        expect(cubit.state.audio.route, CallAudioRoute.speaker);
        verify(
          () => agoraService.setAudioRoute(CallAudioRoute.speaker),
        ).called(1);

        cubit.toggleSpeakerphone();
        expect(cubit.state.audio.route, CallAudioRoute.earpiece);
        verify(
          () => agoraService.setAudioRoute(CallAudioRoute.earpiece),
        ).called(1);
      },
    );

    test(
      'a connected Bluetooth device adds the route and speaker-off returns to it',
      () async {
        await startAcceptedOutgoingCall();
        deviceAudio.devices.add(
          const AudioOutputDevices(bluetoothName: 'Buds'),
        );
        await pumpEventQueue();

        expect(cubit.state.audio.availableRoutes, [
          CallAudioRoute.earpiece,
          CallAudioRoute.speaker,
          CallAudioRoute.bluetooth,
        ]);
        expect(cubit.state.audio.hasRouteChoice, isTrue);

        cubit.selectAudioRoute(CallAudioRoute.speaker);
        cubit.toggleSpeakerphone();
        expect(cubit.state.audio.route, CallAudioRoute.bluetooth);
        verify(
          () => agoraService.setAudioRoute(CallAudioRoute.bluetooth),
        ).called(1);
      },
    );

    test(
      'Bluetooth disconnecting while selected falls back to the earpiece',
      () async {
        await startAcceptedOutgoingCall();
        deviceAudio.devices.add(
          const AudioOutputDevices(bluetoothName: 'Buds'),
        );
        await pumpEventQueue();
        agoraEvents.add(const AgoraAudioRouteChanged(CallAudioRoute.bluetooth));
        await pumpEventQueue();

        deviceAudio.devices.add(AudioOutputDevices.none);
        await pumpEventQueue();

        expect(cubit.state.audio.route, CallAudioRoute.earpiece);
        expect(
          cubit.state.audio.availableRoutes,
          isNot(contains(CallAudioRoute.bluetooth)),
        );
      },
    );

    test('selecting an unavailable route is ignored', () async {
      await startAcceptedOutgoingCall();

      cubit.selectAudioRoute(CallAudioRoute.bluetooth);

      expect(cubit.state.audio.route, CallAudioRoute.earpiece);
      verifyNever(() => agoraService.setAudioRoute(CallAudioRoute.bluetooth));
    });

    test('sound mode changes are mirrored into state', () async {
      await startAcceptedOutgoingCall();
      const silent = DeviceSoundMode(
        ringerMode: DeviceRingerMode.silent,
        isDndOn: false,
      );

      deviceAudio.soundModes.add(silent);
      await pumpEventQueue();

      expect(cubit.state.audio.soundMode, silent);
    });

    test('stops watching device audio when the call ends', () async {
      await startActiveOutgoingCall();
      when(
        () => endCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'ended')));
      await cubit.endCall();
      await pumpEventQueue();

      expect(deviceAudio.devices.hasListener, isFalse);
      expect(deviceAudio.soundModes.hasListener, isFalse);
    });
  });

  group('proximity sensor (screen off at the ear)', () {
    test('is on while an audio call rings and stays on once active', () async {
      when(
        () => initiateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session()));
      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.audio);
      await pumpEventQueue();
      expect(cubit.state.status, CallScreenStatus.ringing);
      expect(proximity.enabled, isTrue);

      await startActiveOutgoingCall();
      expect(cubit.state.status, CallScreenStatus.active);
      expect(proximity.enabled, isTrue);
    });

    test('turns off on speaker and back on for the earpiece', () async {
      await startAcceptedOutgoingCall();
      expect(proximity.enabled, isTrue);

      cubit.toggleSpeakerphone();
      expect(proximity.enabled, isFalse);

      cubit.toggleSpeakerphone();
      expect(proximity.enabled, isTrue);
    });

    test('turns off on a Bluetooth route', () async {
      await startAcceptedOutgoingCall();
      deviceAudio.devices.add(const AudioOutputDevices(bluetoothName: 'Buds'));
      await pumpEventQueue();

      agoraEvents.add(const AgoraAudioRouteChanged(CallAudioRoute.bluetooth));
      await pumpEventQueue();

      expect(proximity.enabled, isFalse);
    });

    test('never turns on for a video call', () async {
      when(
        () => initiateCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session()));
      await cubit.startOutgoingCall(hostId: 'host-1', callType: CallType.video);
      await pumpEventQueue();
      socketEvents.add(
        const CallSocketEvent(callId: 'call-1', status: 'accepted'),
      );
      await pumpEventQueue();

      expect(cubit.state.session?.callType, CallType.video);
      expect(proximity.enabled, isFalse);
    });

    test('turns off when the call ends', () async {
      await startActiveOutgoingCall();
      expect(proximity.enabled, isTrue);

      when(
        () => endCallUseCase(any()),
      ).thenAnswer((_) async => Right(_session(status: 'ended')));
      await cubit.endCall();
      await pumpEventQueue();

      expect(proximity.enabled, isFalse);
    });

    test('turns off on a forced logout', () async {
      await startActiveOutgoingCall();
      forcedLogouts.add(null);
      await pumpEventQueue();

      expect(proximity.enabled, isFalse);
    });

    test('is on for the host once an accepted audio call connects', () async {
      await cubit.startIncomingCall(_session(status: 'accepted'));
      await pumpEventQueue();

      expect(cubit.state.status, CallScreenStatus.connecting);
      expect(proximity.enabled, isTrue);
    });
  });
}
