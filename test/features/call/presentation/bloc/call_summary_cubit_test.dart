// Regression safety net for CallSummaryCubit's post-call numbers. This
// dialog is the only place billing/duration numbers are ever shown to the
// user, so it must never silently show 0 for a call that plainly ran, nor
// re-query the server so eagerly that it catches an in-progress billing
// calculation and shows a bogus, too-small duration — and it must never
// block the whole popup behind a loading skeleton for several seconds on
// the hope a retry will help, since some backend billing bugs are
// permanent (re-querying never helps) rather than a timing lag.
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_session_entity.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/get_call_details_usecase.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_summary_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetCallDetailsUseCase extends Mock implements GetCallDetailsUseCase {}

CallSessionEntity _session({
  int duration = 0,
  int billedMinutes = 0,
  int totalPointsDebited = 0,
}) {
  return CallSessionEntity(
    callId: 'call-1',
    agoraChannel: 'channel-1',
    agoraToken: 'token-1',
    status: 'ended',
    callType: CallType.audio,
    duration: duration,
    billedMinutes: billedMinutes,
    totalPointsDebited: totalPointsDebited,
    ratePerMinute: 10,
    endReason: 'ended_by_user',
    hostId: 'host-1',
    callerId: 'caller-1',
  );
}

void main() {
  late _MockGetCallDetailsUseCase getCallDetailsUseCase;

  setUp(() {
    getCallDetailsUseCase = _MockGetCallDetailsUseCase();
  });

  test(
    'shows the passed-in session immediately without hitting the network '
    'when it already carries real billing numbers',
    () async {
      final cubit = CallSummaryCubit(
        session: _session(duration: 125, billedMinutes: 3, totalPointsDebited: 30),
        isHost: false,
        getCallDetailsUseCase: getCallDetailsUseCase,
      );

      // No await at all — this must already be the final state synchronously.
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, '2m 5s');
      expect(cubit.state.billedMinutes, 3);
      expect(cubit.state.pointsValue, 30);
      verifyNever(() => getCallDetailsUseCase(any()));

      await cubit.close();
    },
  );

  test(
    'shows the best data on hand immediately even when it is not yet '
    'finalized, instead of blocking behind a loading skeleton while it '
    'polls in the background',
    () async {
      when(() => getCallDetailsUseCase(any()))
          .thenAnswer((_) async => Right(_session()));

      final cubit = CallSummaryCubit(
        session: _session(),
        isHost: true,
        localDurationSeconds: 130,
        getCallDetailsUseCase: getCallDetailsUseCase,
      );

      // Must already be showing something useful right away — never stuck
      // on isLoading while the background refinement runs.
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, '2m 10s');

      await cubit.close();
    },
  );

  test(
    'silently upgrades the displayed numbers in the background once the '
    'server catches up, without ever re-showing a loading state',
    () async {
      var attempt = 0;
      when(() => getCallDetailsUseCase(any())).thenAnswer((_) async {
        attempt++;
        // Simulate the backend's async billing computation finishing on
        // the second poll.
        if (attempt < 2) {
          return Right(_session());
        }
        return Right(_session(duration: 130, billedMinutes: 3, totalPointsDebited: 30));
      });

      final cubit = CallSummaryCubit(
        session: _session(),
        isHost: true,
        localDurationSeconds: 130,
        getCallDetailsUseCase: getCallDetailsUseCase,
      );

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.billedMinutes, 0);

      // First retry fires after 1s, second after another 2s.
      await Future<void>.delayed(const Duration(seconds: 3, milliseconds: 500));

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, '2m 10s');
      expect(cubit.state.billedMinutes, 3);
      expect(cubit.state.pointsValue, 30);
      expect(attempt, 2);

      await cubit.close();
    },
  );

  test(
    'falls back to this device\'s own tracked duration instead of showing '
    '0s when the server never catches up within the retry window',
    () async {
      when(() => getCallDetailsUseCase(any()))
          .thenAnswer((_) async => Right(_session()));

      final cubit = CallSummaryCubit(
        session: _session(),
        isHost: false,
        localDurationSeconds: 95,
        getCallDetailsUseCase: getCallDetailsUseCase,
      );

      // Duration falls back to the locally-tracked value instead of "0s"
      // immediately — no need to wait for retries to see it.
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, '1m 35s');

      // All three retries (1s + 2s + 3s) must be exhausted before giving up.
      await Future<void>.delayed(const Duration(seconds: 6, milliseconds: 500));

      expect(cubit.state.isLoading, isFalse);
      // billedMinutes/points can't be guessed locally, so those stay
      // honest about what the server actually reported (0).
      expect(cubit.state.durationText, '1m 35s');
      expect(cubit.state.billedMinutes, 0);
      expect(cubit.state.pointsValue, 0);
      verify(() => getCallDetailsUseCase('call-1')).called(3);

      await cubit.close();
    },
  );

  test(
    'a real 1-minute call whose /end response reports an implausibly small '
    'non-zero duration (e.g. "7s") is shown using the device\'s own '
    'tracked duration immediately, and stays that way if the server never '
    'corrects it',
    () async {
      // Reproduces the exact reported bug: call ran a full minute
      // (localDurationSeconds: 60), but the passed-in session — and every
      // subsequent refetch — reports only 7s. A naive ">0" check would
      // accept "7" as already finalized on the very first look and show it
      // immediately; it must instead be recognized as implausible and
      // substituted with the locally tracked duration right away.
      when(() => getCallDetailsUseCase(any()))
          .thenAnswer((_) async => Right(_session(duration: 7)));

      final cubit = CallSummaryCubit(
        session: _session(duration: 7),
        isHost: true,
        localDurationSeconds: 60,
        getCallDetailsUseCase: getCallDetailsUseCase,
      );

      // The implausible "7s" must never be shown, not even for a moment.
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, '1m 0s');

      await Future<void>.delayed(const Duration(seconds: 6, milliseconds: 500));

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, '1m 0s');
      verify(() => getCallDetailsUseCase('call-1')).called(3);

      await cubit.close();
    },
  );

  test(
    'a server duration that later self-corrects to match the tracked '
    'duration is trusted once it catches up',
    () async {
      var attempt = 0;
      when(() => getCallDetailsUseCase(any())).thenAnswer((_) async {
        attempt++;
        if (attempt < 2) {
          return Right(_session(duration: 7));
        }
        return Right(_session(duration: 61, billedMinutes: 1, totalPointsDebited: 10));
      });

      final cubit = CallSummaryCubit(
        session: _session(duration: 7),
        isHost: true,
        localDurationSeconds: 60,
        getCallDetailsUseCase: getCallDetailsUseCase,
      );

      await Future<void>.delayed(const Duration(seconds: 3, milliseconds: 500));

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, '1m 1s');
      expect(cubit.state.billedMinutes, 1);
      expect(cubit.state.pointsValue, 10);
      expect(attempt, 2);

      await cubit.close();
    },
  );

  test(
    'a 4-minute call whose /end response has a correct duration but '
    'billedMinutes stuck at 0 shows the correct duration immediately, '
    'and billing catches up in the background once it clears',
    () async {
      // Reproduces the exact reported bug: duration is right immediately
      // (240s, matching the 240s locally tracked), so a duration-only check
      // would treat this as "finalized" and never even attempt a retry —
      // even though billedMinutes/totalPointsDebited are still sitting at 0
      // in that same response.
      var attempt = 0;
      when(() => getCallDetailsUseCase(any())).thenAnswer((_) async {
        attempt++;
        if (attempt < 2) {
          return Right(_session(duration: 240));
        }
        return Right(_session(duration: 240, billedMinutes: 4, totalPointsDebited: 40));
      });

      final cubit = CallSummaryCubit(
        session: _session(duration: 240),
        isHost: false,
        localDurationSeconds: 240,
        getCallDetailsUseCase: getCallDetailsUseCase,
      );

      // Duration is already correct, so it shows immediately — billing is
      // still 0 until the background refinement catches up.
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, '4m 0s');
      expect(cubit.state.billedMinutes, 0);

      await Future<void>.delayed(const Duration(seconds: 3, milliseconds: 500));

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, '4m 0s');
      expect(cubit.state.billedMinutes, 4);
      expect(cubit.state.pointsValue, 40);
      expect(attempt, 2);

      await cubit.close();
    },
  );

  test(
    'if the server never computes billedMinutes/points within the retry '
    'window (a permanent backend bug, not a timing lag), the correct '
    'duration is still shown honestly alongside 0 billing — it does not '
    'fabricate numbers it cannot know, and never leaves the popup blank '
    'while it tries',
    () async {
      when(() => getCallDetailsUseCase(any()))
          .thenAnswer((_) async => Right(_session(duration: 240)));

      final cubit = CallSummaryCubit(
        session: _session(duration: 240),
        isHost: true,
        localDurationSeconds: 240,
        getCallDetailsUseCase: getCallDetailsUseCase,
      );

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, '4m 0s');
      expect(cubit.state.billedMinutes, 0);

      await Future<void>.delayed(const Duration(seconds: 6, milliseconds: 500));

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, '4m 0s');
      expect(cubit.state.billedMinutes, 0);
      expect(cubit.state.pointsValue, 0);
      verify(() => getCallDetailsUseCase('call-1')).called(3);

      await cubit.close();
    },
  );
}
