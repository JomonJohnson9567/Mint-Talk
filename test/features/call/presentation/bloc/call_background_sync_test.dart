import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/services/call_background/i_call_background_service.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_background_sync.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';

class _RecordingBackgroundService implements ICallBackgroundService {
  final List<OngoingCallInfo> shown = [];
  final List<bool> pip = [];
  int hides = 0;
  bool showResult = true;

  @override
  bool isSupported = true;

  @override
  Stream<CallBackgroundAction> get actions => const Stream.empty();

  @override
  Stream<bool> get pipModeChanges => const Stream.empty();

  @override
  Future<void> hideOngoingCall() async => hides++;

  @override
  Future<void> setPipEnabled(bool enabled) async => pip.add(enabled);

  @override
  Future<bool> showOngoingCall(OngoingCallInfo info) async {
    shown.add(info);
    return showResult;
  }
}

CallScreenState _state({
  CallScreenStatus status = CallScreenStatus.ringing,
  CallType callType = CallType.audio,
  int durationSeconds = 0,
  bool isMuted = false,
}) => CallScreenState(
  status: status,
  callType: callType,
  displayName: 'Asha',
  durationSeconds: durationSeconds,
  isMuted: isMuted,
);

void main() {
  late _RecordingBackgroundService service;
  late DateTime now;
  late CallBackgroundSync sync;

  setUp(() {
    service = _RecordingBackgroundService();
    now = DateTime(2026, 11, 5, 10);
    sync = CallBackgroundSync(service, now: () => now);
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('shows the call while ringing, with no timer yet', () async {
    sync.sync(_state());
    await settle();

    expect(service.shown, hasLength(1));
    expect(service.shown.single.displayName, 'Asha');
    expect(service.shown.single.statusText, AppTexts.ringingEllipsis);
    expect(service.shown.single.chronometerBaseEpochMs, isNull);
  });

  test('duration ticks do not re-send the notification', () async {
    sync.sync(_state(status: CallScreenStatus.active, durationSeconds: 1));
    await settle();
    sync.sync(_state(status: CallScreenStatus.active, durationSeconds: 2));
    sync.sync(_state(status: CallScreenStatus.active, durationSeconds: 3));
    await settle();

    expect(service.shown, hasLength(1));
    expect(
      service.shown.single.chronometerBaseEpochMs,
      now.millisecondsSinceEpoch - 1000,
    );
  });

  test('timer re-bases only when the call timer is corrected', () async {
    sync.sync(_state(status: CallScreenStatus.active));
    await settle();
    final base = now.millisecondsSinceEpoch;

    // Normal ticks: wall clock and duration advance together.
    now = now.add(const Duration(seconds: 5));
    sync.sync(_state(status: CallScreenStatus.active, durationSeconds: 5));
    await settle();
    expect(service.shown, hasLength(1));

    // Server activeAt correction: the call screen jumps ahead 30 s.
    sync.sync(_state(status: CallScreenStatus.active, durationSeconds: 35));
    await settle();
    expect(service.shown, hasLength(2));
    expect(service.shown.last.chronometerBaseEpochMs, base - 30000);
  });

  test('a mute change updates the notification', () async {
    sync.sync(_state(status: CallScreenStatus.active));
    await settle();
    sync.sync(_state(status: CallScreenStatus.active, isMuted: true));
    await settle();

    expect(service.shown.map((i) => i.isMuted), [false, true]);
  });

  test(
    'a change while a show is in flight is sent once it completes',
    () async {
      final gate = Completer<bool>();
      final gated = _GatedService(gate.future);
      final gatedSync = CallBackgroundSync(gated, now: () => now);

      gatedSync.sync(_state(status: CallScreenStatus.active));
      gatedSync.sync(_state(status: CallScreenStatus.active, isMuted: true));
      expect(gated.shown, hasLength(1));

      gate.complete(true);
      await settle();
      expect(gated.shown.map((i) => i.isMuted), [false, true]);
    },
  );

  test('a failed show is retried on a later change, throttled', () async {
    service.showResult = false;
    sync.sync(_state(status: CallScreenStatus.connecting));
    await settle();
    sync.sync(_state(status: CallScreenStatus.connecting));
    await settle();
    expect(service.shown, hasLength(1), reason: 'throttled');

    service.showResult = true;
    now = now.add(CallBackgroundSync.retryInterval);
    sync.sync(_state(status: CallScreenStatus.connecting));
    await settle();
    expect(service.shown, hasLength(2));
  });

  test('picture-in-picture only for an active video call', () async {
    sync.sync(_state(callType: CallType.video));
    sync.sync(
      _state(status: CallScreenStatus.active, callType: CallType.audio),
    );
    expect(service.pip, isEmpty);

    sync.sync(
      _state(status: CallScreenStatus.active, callType: CallType.video),
    );
    expect(service.pip, [true]);
  });

  test('call end hides the notification and disables PiP', () async {
    sync.sync(
      _state(status: CallScreenStatus.active, callType: CallType.video),
    );
    await settle();
    sync.sync(_state(status: CallScreenStatus.ended, callType: CallType.video));
    await settle();

    expect(service.hides, 1);
    expect(service.pip, [true, false]);

    // Idempotent.
    sync.stop();
    expect(service.hides, 1);
  });

  test('does nothing on unsupported platforms', () async {
    service.isSupported = false;
    sync.sync(
      _state(status: CallScreenStatus.active, callType: CallType.video),
    );
    sync.stop();
    await settle();

    expect(service.shown, isEmpty);
    expect(service.pip, isEmpty);
    expect(service.hides, 0);
  });
}

class _GatedService extends _RecordingBackgroundService {
  final Future<bool> _firstResult;
  bool _first = true;

  _GatedService(this._firstResult);

  @override
  Future<bool> showOngoingCall(OngoingCallInfo info) {
    shown.add(info);
    if (_first) {
      _first = false;
      return _firstResult;
    }
    return Future.value(true);
  }
}
