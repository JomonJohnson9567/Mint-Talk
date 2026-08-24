// Regression safety net for CallSummaryCubit's post-call numbers. This
// dialog is the only place billing/duration numbers are ever shown to the
// user, so each of duration/billedMinutes/points must only ever display a
// real value that actually came from the server — never a locally guessed
// substitute. While a field hasn't been confirmed yet it stays null (the
// dialog renders a skeleton for it) rather than showing something that
// didn't come from the response.
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
    'shows a skeleton (null) for duration and billing while the passed-in '
    'session has no data yet, instead of fabricating a number',
    () async {
      when(() => getCallDetailsUseCase(any()))
          .thenAnswer((_) async => Right(_session()));

      final cubit = CallSummaryCubit(
        session: _session(),
        isHost: true,
        localDurationSeconds: 130,
        getCallDetailsUseCase: getCallDetailsUseCase,
      );

      // Header copy is available immediately (from the local tally), but
      // the numeric stats must stay null (skeleton) until the server
      // actually confirms them — never substituted with the local value.
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.title, isNotEmpty);
      expect(cubit.state.durationText, isNull);
      expect(cubit.state.billedMinutes, isNull);
      expect(cubit.state.pointsValue, isNull);

      await cubit.close();
    },
  );

  test(
    'reveals duration and billing independently, as soon as each one '
    'individually looks trustworthy, without waiting on the other',
    () async {
      var attempt = 0;
      when(() => getCallDetailsUseCase(any())).thenAnswer((_) async {
        attempt++;
        // Billing arrives on the first retry; duration only catches up on
        // the second — reproduces the reported bug where billedMinutes/
        // points update but duration does not, in the same response cycle.
        if (attempt == 1) {
          return Right(_session(billedMinutes: 3, totalPointsDebited: 30));
        }
        return Right(_session(duration: 130, billedMinutes: 3, totalPointsDebited: 30));
      });

      final cubit = CallSummaryCubit(
        session: _session(),
        isHost: true,
        localDurationSeconds: 130,
        getCallDetailsUseCase: getCallDetailsUseCase,
      );

      expect(cubit.state.durationText, isNull);
      expect(cubit.state.billedMinutes, isNull);

      // First retry (1s) resolves billing but not duration.
      await Future<void>.delayed(const Duration(seconds: 1, milliseconds: 300));
      expect(cubit.state.billedMinutes, 3);
      expect(cubit.state.pointsValue, 30);
      expect(cubit.state.durationText, isNull);

      // Second retry (another 2s) resolves duration too.
      await Future<void>.delayed(const Duration(seconds: 2, milliseconds: 300));
      expect(cubit.state.durationText, '2m 10s');
      expect(attempt, 2);

      await cubit.close();
    },
  );

  test(
    'never substitutes the locally tracked duration for the server value — '
    'keeps showing a skeleton until the retry window gives up, then reveals '
    'the real (possibly zero) response as-is',
    () async {
      when(() => getCallDetailsUseCase(any()))
          .thenAnswer((_) async => Right(_session()));

      final cubit = CallSummaryCubit(
        session: _session(),
        isHost: false,
        localDurationSeconds: 95,
        getCallDetailsUseCase: getCallDetailsUseCase,
      );

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, isNull);

      // All three retries (1s + 2s + 3s) must be exhausted before giving up.
      await Future<void>.delayed(const Duration(seconds: 6, milliseconds: 500));

      // The server never reported a real duration — shown honestly as 0s,
      // never silently swapped for the local 95s tally.
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, '0s');
      expect(cubit.state.billedMinutes, 0);
      expect(cubit.state.pointsValue, 0);
      verify(() => getCallDetailsUseCase('call-1')).called(3);

      await cubit.close();
    },
  );

  test(
    'a real 1-minute call whose /end response reports an implausibly small '
    'non-zero duration (e.g. "7s") stays a skeleton through the retry '
    'window, then reveals that 7s response as-is once retries give up',
    () async {
      // Reproduces the exact reported bug: call ran a full minute
      // (localDurationSeconds: 60), but the passed-in session — and every
      // subsequent refetch — reports only 7s. A naive ">0" check would
      // accept "7" as already finalized on the very first look; it must
      // instead be recognized as implausible and held back as a skeleton.
      when(() => getCallDetailsUseCase(any()))
          .thenAnswer((_) async => Right(_session(duration: 7)));

      final cubit = CallSummaryCubit(
        session: _session(duration: 7),
        isHost: true,
        localDurationSeconds: 60,
        getCallDetailsUseCase: getCallDetailsUseCase,
      );

      // The implausible "7s" must never be shown while retries remain.
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, isNull);

      await Future<void>.delayed(const Duration(seconds: 6, milliseconds: 500));

      // Retries exhausted — the server's real (if implausible) answer is
      // revealed as-is, never the local 60s tally.
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, '7s');
      verify(() => getCallDetailsUseCase('call-1')).called(3);

      await cubit.close();
    },
  );

  test(
    'a server duration that later self-corrects to match the tracked '
    'duration is revealed once it catches up',
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

      // Duration is already correct, so it shows immediately — billing
      // stays a skeleton until the background refinement catches up.
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.durationText, '4m 0s');
      expect(cubit.state.billedMinutes, isNull);

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
    'duration is still shown immediately alongside a billing skeleton, '
    'which then reveals 0 once the retry window gives up',
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
      expect(cubit.state.billedMinutes, isNull);

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
