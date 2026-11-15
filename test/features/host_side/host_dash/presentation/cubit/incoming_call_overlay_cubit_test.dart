import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/services/audio/incoming_ringer_service.dart';
import 'package:mint_talk/core/services/incoming_call_alert/i_incoming_call_alert_service.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/incoming_call_overlay_cubit.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/incoming_call_overlay_state.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_session_entity.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/reject_call_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockPresenceSocketService extends Mock implements IPresenceSocketService {}

class _MockRejectCallUseCase extends Mock implements RejectCallUseCase {}

class _FakeRinger implements IIncomingRingerService {
  bool isPlaying = false;

  @override
  Future<void> start() async => isPlaying = true;

  @override
  Future<void> stop() async => isPlaying = false;
}

class _FakeAlertService implements IIncomingCallAlertService {
  final actionsController = StreamController<IncomingCallAction>.broadcast();
  IncomingCallAlert? shown;
  int hideCount = 0;
  int clearLockCount = 0;

  @override
  bool get isSupported => true;

  @override
  Stream<IncomingCallAction> get actions => actionsController.stream;

  @override
  Future<bool> showIncomingCall(IncomingCallAlert alert) async {
    shown = alert;
    return true;
  }

  @override
  Future<void> hideIncomingCall() async {
    shown = null;
    hideCount++;
  }

  @override
  Future<void> clearLockScreenOverride() async => clearLockCount++;

  @override
  Future<bool> startHostStandby({
    required bool audio,
    required bool video,
  }) async => true;

  @override
  Future<void> stopHostStandby() async {}
}

const _rejected = CallSessionEntity(
  callId: 'call-1',
  status: 'rejected',
  callType: CallType.video,
  duration: 0,
  billedUnits: 0,
  totalPointsDebited: 0,
  ratePerMinute: 0,
  endReason: '',
  hostId: 'host-1',
  callerId: 'caller-1',
);

Map<String, dynamic> _incoming({
  String callId = 'call-1',
  Duration ringLeft = const Duration(seconds: 10),
}) => {
  'callId': callId,
  'callerId': 'caller-1',
  'callerName': 'Caller',
  'hostId': 'host-1',
  'callType': 'video',
  'ringExpiresAt': DateTime.now().add(ringLeft).toIso8601String(),
};

void main() {
  late _MockPresenceSocketService socket;
  late _MockRejectCallUseCase rejectCall;
  late _FakeRinger ringer;
  late _FakeAlertService alerts;
  late StreamController<Map<String, dynamic>> incomingCalls;
  late StreamController<Map<String, dynamic>> statusUpdates;
  late StreamController<AppLifecycleState> lifecycle;
  late IncomingCallOverlayCubit cubit;

  IncomingCallOverlayCubit build(AppLifecycleState initial) =>
      IncomingCallOverlayCubit(
        presenceSocketService: socket,
        incomingCallAlertService: alerts,
        ringtone: ringer,
        rejectCallUseCase: rejectCall,
        lifecycleChanges: lifecycle.stream,
        initialLifecycleState: initial,
      );

  Future<void> settle() => pumpEventQueue();

  setUp(() {
    socket = _MockPresenceSocketService();
    rejectCall = _MockRejectCallUseCase();
    ringer = _FakeRinger();
    alerts = _FakeAlertService();
    incomingCalls = StreamController<Map<String, dynamic>>.broadcast();
    statusUpdates = StreamController<Map<String, dynamic>>.broadcast();
    lifecycle = StreamController<AppLifecycleState>.broadcast();

    when(() => socket.incomingCalls).thenAnswer((_) => incomingCalls.stream);
    when(() => socket.callStatusUpdates).thenAnswer((_) => statusUpdates.stream);
    when(() => socket.subscribeCall(any())).thenReturn(null);
    when(() => socket.unsubscribeCall(any())).thenReturn(null);
    when(() => rejectCall(any())).thenAnswer((_) async => const Right(_rejected));
  });

  tearDown(() async {
    await cubit.close();
    await incomingCalls.close();
    await statusUpdates.close();
    await lifecycle.close();
  });

  group('in the foreground', () {
    setUp(() => cubit = build(AppLifecycleState.resumed));

    test('shows the ringing screen and leaves ringing to it', () async {
      incomingCalls.add(_incoming());
      await settle();

      expect(cubit.state.showRequest, 1);
      expect(cubit.state.payload?.callId, 'call-1');
      expect(cubit.state.autoAccept, isFalse);
      expect(ringer.isPlaying, isFalse);
      expect(alerts.shown, isNull);
    });

    test('ignores a second call while one is ringing', () async {
      incomingCalls.add(_incoming());
      await settle();
      incomingCalls.add(_incoming(callId: 'call-2'));
      await settle();

      expect(cubit.state.showRequest, 1);
      expect(cubit.state.payload?.callId, 'call-1');
    });

    test('leaving the app while ringing shows the notification', () async {
      incomingCalls.add(_incoming());
      await settle();

      lifecycle.add(AppLifecycleState.hidden);
      await settle();

      expect(alerts.shown?.callId, 'call-1');
      expect(alerts.shown?.isVideo, isTrue);
    });

    test('notification Decline while the screen is up sends a decline command', () async {
      incomingCalls.add(_incoming());
      await settle();
      lifecycle.add(AppLifecycleState.paused);
      await settle();

      alerts.actionsController.add(
        const IncomingCallAction(IncomingCallActionType.decline, 'call-1'),
      );
      await settle();

      expect(cubit.state.command, IncomingCallCommand.decline);
      expect(cubit.state.commandRequest, 1);
      expect(alerts.shown, isNull);
      verifyNever(() => rejectCall(any()));
    });

    test('a dismissed call frees the overlay for the next call', () async {
      incomingCalls.add(_incoming());
      await settle();
      cubit.dialogDismissed();
      incomingCalls.add(_incoming(callId: 'call-2'));
      await settle();

      expect(cubit.state.showRequest, 2);
      expect(cubit.state.payload?.callId, 'call-2');
      expect(alerts.clearLockCount, 1);
    });

    test('an accepted call keeps the lock-screen override for the call', () async {
      incomingCalls.add(_incoming());
      await settle();
      cubit.callAccepted();
      cubit.dialogDismissed();

      expect(alerts.clearLockCount, 0);
    });
  });

  group('while minimized', () {
    setUp(() => cubit = build(AppLifecycleState.paused));

    test('rings and shows the notification instead of the screen', () async {
      incomingCalls.add(_incoming());
      await settle();

      expect(cubit.state.showRequest, 0);
      expect(ringer.isPlaying, isTrue);
      expect(alerts.shown?.callId, 'call-1');
      expect(alerts.shown?.callerName, 'Caller');
      verify(() => socket.subscribeCall('call-1')).called(1);
    });

    test('ignores a call whose ring window already closed', () async {
      incomingCalls.add(_incoming(ringLeft: const Duration(seconds: -1)));
      await settle();

      expect(ringer.isPlaying, isFalse);
      expect(alerts.shown, isNull);
    });

    test('coming back hides the notification and shows the screen', () async {
      incomingCalls.add(_incoming());
      await settle();

      lifecycle.add(AppLifecycleState.resumed);
      await settle();

      expect(alerts.shown, isNull);
      expect(cubit.state.showRequest, 1);
      expect(cubit.state.payload?.callId, 'call-1');
      // The screen's session cubit takes the ringer and subscription over.
      expect(ringer.isPlaying, isTrue);
      verifyNever(() => socket.unsubscribeCall(any()));
    });

    test('pins the fallback deadline when the server sent none', () async {
      incomingCalls.add(_incoming()..remove('ringExpiresAt'));
      await settle();
      lifecycle.add(AppLifecycleState.resumed);
      await settle();

      expect(cubit.state.payload?.ringExpiresAt, isNotNull);
    });

    test('the caller cancelling stops ringing and cleans up', () async {
      incomingCalls.add(_incoming());
      await settle();

      statusUpdates.add({'callId': 'call-1', 'status': 'cancelled'});
      await settle();

      expect(ringer.isPlaying, isFalse);
      expect(alerts.shown, isNull);
      verify(() => socket.unsubscribeCall('call-1')).called(1);
      expect(alerts.clearLockCount, 1);

      lifecycle.add(AppLifecycleState.resumed);
      await settle();
      expect(cubit.state.showRequest, 0);
    });

    test("another call's terminal event is ignored", () async {
      incomingCalls.add(_incoming());
      await settle();

      statusUpdates.add({'callId': 'call-9', 'status': 'ended'});
      await settle();

      expect(ringer.isPlaying, isTrue);
      expect(alerts.shown?.callId, 'call-1');
    });

    test('the ring window closing stops ringing', () async {
      incomingCalls.add(_incoming(ringLeft: const Duration(milliseconds: 80)));
      await settle();
      expect(ringer.isPlaying, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect(ringer.isPlaying, isFalse);
      expect(alerts.shown, isNull);
      verify(() => socket.unsubscribeCall('call-1')).called(1);
    });

    test('Answer shows the screen set to accept at once', () async {
      incomingCalls.add(_incoming());
      await settle();

      alerts.actionsController.add(
        const IncomingCallAction(IncomingCallActionType.answer, 'call-1'),
      );
      await settle();

      expect(cubit.state.showRequest, 1);
      expect(cubit.state.autoAccept, isTrue);
      expect(alerts.shown, isNull);
    });

    test('Decline rejects the call and cleans up', () async {
      incomingCalls.add(_incoming());
      await settle();

      alerts.actionsController.add(
        const IncomingCallAction(IncomingCallActionType.decline, 'call-1'),
      );
      await settle();

      verify(() => rejectCall('call-1')).called(1);
      expect(ringer.isPlaying, isFalse);
      expect(alerts.shown, isNull);
      expect(cubit.state.showRequest, 0);
      verify(() => socket.unsubscribeCall('call-1')).called(1);
    });

    test('an action for a different call is ignored', () async {
      incomingCalls.add(_incoming());
      await settle();

      alerts.actionsController.add(
        const IncomingCallAction(IncomingCallActionType.decline, 'call-old'),
      );
      await settle();

      verifyNever(() => rejectCall(any()));
      expect(ringer.isPlaying, isTrue);
    });

    test('a stale Answer with nothing ringing clears the lock-screen override', () async {
      alerts.actionsController.add(
        const IncomingCallAction(IncomingCallActionType.answer, 'call-old'),
      );
      await settle();

      expect(alerts.clearLockCount, 1);
      expect(cubit.state.showRequest, 0);
    });

    test('closing while ringing in the background stops everything', () async {
      incomingCalls.add(_incoming());
      await settle();

      await cubit.close();

      expect(ringer.isPlaying, isFalse);
      expect(alerts.shown, isNull);
    });
  });
}
