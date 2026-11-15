import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/services/audio/incoming_ringer_service.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/incoming_call_session_cubit.dart';
import 'package:mint_talk/features/user_side/call/data/models/incoming_call_payload_dto.dart';
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

const _payload = IncomingCallPayloadDto(
  callId: 'call-1',
  callerId: 'caller-1',
  callerName: 'Caller',
  hostId: 'host-1',
  callType: CallType.audio,
);

void main() {
  const shortLimit = Duration(milliseconds: 50);
  const pastLimit = Duration(milliseconds: 120);

  late _MockPresenceSocketService socket;
  late _MockRejectCallUseCase rejectCall;
  late _FakeRinger ringer;
  late StreamController<Map<String, dynamic>> statusUpdates;
  late int dismissCount;
  late IncomingCallSessionCubit cubit;

  setUp(() {
    IncomingCallSessionCubit.ringTimeout = shortLimit;
    socket = _MockPresenceSocketService();
    rejectCall = _MockRejectCallUseCase();
    ringer = _FakeRinger();
    statusUpdates = StreamController<Map<String, dynamic>>.broadcast();
    dismissCount = 0;

    when(() => socket.callStatusUpdates).thenAnswer((_) => statusUpdates.stream);
    when(() => socket.subscribeCall(any())).thenReturn(null);
    when(() => socket.unsubscribeCall(any())).thenReturn(null);
    when(() => rejectCall(any())).thenAnswer(
      (_) async => const Right(
        CallSessionEntity(
          callId: 'call-1',
          status: 'rejected',
          callType: CallType.audio,
          duration: 0,
          billedUnits: 0,
          totalPointsDebited: 0,
          ratePerMinute: 0,
          endReason: '',
          hostId: 'host-1',
          callerId: 'caller-1',
        ),
      ),
    );

    cubit = IncomingCallSessionCubit(
      payload: _payload,
      onDismiss: () => dismissCount++,
      presenceSocketService: socket,
      rejectCallUseCase: rejectCall,
      ringtone: ringer,
    );
  });

  tearDown(() async {
    IncomingCallSessionCubit.ringTimeout = const Duration(seconds: 20);
    await cubit.close();
    await statusUpdates.close();
  });

  test('unanswered at the ring limit → overlay closes and ringtone stops, no reject', () async {
    await pumpEventQueue();
    expect(ringer.isPlaying, isTrue);

    await Future<void>.delayed(pastLimit);

    expect(dismissCount, 1);
    expect(ringer.isPlaying, isFalse);
    expect(cubit.state.isProcessing, isTrue);
    verifyNever(() => rejectCall(any()));
  });

  test('caller cancels before the limit → dismissed exactly once', () async {
    statusUpdates.add({'callId': 'call-1', 'status': 'cancelled'});
    await pumpEventQueue();
    expect(dismissCount, 1);

    await Future<void>.delayed(pastLimit);
    expect(dismissCount, 1);
  });

  test('host accepts before the limit → overlay is not dismissed', () async {
    cubit.handOffToCallScreen();

    await Future<void>.delayed(pastLimit);

    expect(dismissCount, 0);
  });

  test('host rejects before the limit → dismissed once by the reject only', () async {
    await cubit.reject();
    expect(dismissCount, 1);

    await Future<void>.delayed(pastLimit);
    expect(dismissCount, 1);
    verify(() => rejectCall('call-1')).called(1);
  });

  group('ringExpiresAt', () {
    // Separate from dismissCount: the setUp cubit rings on the short
    // fallback and would otherwise be counted too.
    var deadlineDismissals = 0;
    setUp(() => deadlineDismissals = 0);

    IncomingCallSessionCubit build(DateTime expiresAt, DateTime serverNow) {
      return IncomingCallSessionCubit(
        payload: IncomingCallPayloadDto(
          callId: 'call-2',
          callerId: 'caller-1',
          callerName: 'Caller',
          hostId: 'host-1',
          callType: CallType.video,
          ringExpiresAt: expiresAt,
        ),
        onDismiss: () => deadlineDismissals++,
        presenceSocketService: socket,
        rejectCallUseCase: rejectCall,
        ringtone: ringer,
        serverNow: () => serverNow,
      );
    }

    test('closes at the server deadline, not the fallback', () async {
      // The fallback is long and the server deadline short: the deadline wins.
      IncomingCallSessionCubit.ringTimeout = const Duration(seconds: 20);
      final now = DateTime(2026, 11, 10, 12);
      final session = build(now.add(shortLimit), now);
      addTearDown(session.close);

      await Future<void>.delayed(pastLimit);

      expect(session.state.isProcessing, isTrue);
      expect(deadlineDismissals, 1);
    });

    test('an already-expired push closes immediately', () async {
      final now = DateTime(2026, 11, 10, 12);
      final session = build(now.subtract(const Duration(seconds: 5)), now);
      addTearDown(session.close);

      await Future<void>.delayed(Duration.zero);

      expect(session.state.isProcessing, isTrue);
    });

    test('accepting cancels the deadline timer', () async {
      IncomingCallSessionCubit.ringTimeout = const Duration(seconds: 20);
      final now = DateTime(2026, 11, 10, 12);
      final session = build(now.add(shortLimit), now);
      addTearDown(session.close);

      session.handOffToCallScreen();
      await Future<void>.delayed(pastLimit);

      expect(deadlineDismissals, 0);
    });
  });

  test('terminal failed status closes the ringing overlay', () async {
    statusUpdates.add({'callId': 'call-1', 'status': 'failed'});
    await pumpEventQueue();
    expect(dismissCount, 1);
  });
}
