import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import '../../domain/entities/call_session_entity.dart';
import '../../domain/usecases/get_call_details_usecase.dart';
import 'call_summary_state.dart';

class CallSummaryCubit extends Cubit<CallSummaryState> {
  final GetCallDetailsUseCase _getCallDetailsUseCase;
  final String callId;
  final bool isHost;

  /// This device's own second-by-second tally of the call
  /// (CallScreenState.durationSeconds) while it was active — independent of
  /// anything the server reports. Used only as a cross-check/fallback: it
  /// proves the call genuinely ran for real time even if the server's own
  /// billing numbers haven't caught up yet by the time this dialog opens.
  final int _localDurationSeconds;

  /// Builds the summary from the [session] CallScreenCubit hands over,
  /// which is normally already finalized — it merges the real duration/
  /// billedMinutes/totalPointsDebited from the /end (or socket `ended`)
  /// response before ever emitting the `ended` status (see the comments
  /// around `endCall()`/`_mergeBillingFields` in CallScreenCubit).
  ///
  /// Occasionally the backend's own async billing computation is still a
  /// beat behind that response, so [session] lands here with those fields
  /// still at 0 even though the call plainly ran (that's what
  /// [localDurationSeconds] proves). In that case only, this polls
  /// GetCallDetailsUseCase a few times with backoff — never an instant,
  /// single re-query, which is what previously caught the server
  /// mid-calculation and showed a bogus few-seconds duration for a call
  /// that ran for minutes.
  CallSummaryCubit({
    required CallSessionEntity session,
    required this.isHost,
    int localDurationSeconds = 0,
    GetCallDetailsUseCase? getCallDetailsUseCase,
  })  : _getCallDetailsUseCase = getCallDetailsUseCase ?? getIt<GetCallDetailsUseCase>(),
        _localDurationSeconds = localDurationSeconds,
        callId = session.callId,
        super(CallSummaryState.loading(isHost: isHost)) {
    _resolveFinalSession(session);
  }

  /// A server duration doesn't just need to be non-zero to be trustworthy —
  /// it needs to be in the same ballpark as what this device itself measured
  /// second-by-second while the call was active. A 1-minute call whose /end
  /// response reports "7s" is not "finalized with a small value", it's the
  /// backend's billing computation returning an interim/partial number
  /// before it finished — exactly the failure mode this cross-check exists
  /// to catch, since a naive ">0" check would wrongly accept it as done.
  static const _durationToleranceSeconds = 10;

  bool _looksFinalized(CallSessionEntity s) {
    final hasBillingSignal =
        s.duration > 0 || s.billedMinutes > 0 || s.totalPointsDebited > 0;
    if (!hasBillingSignal) return false;

    if (_localDurationSeconds > 0 &&
        s.duration < _localDurationSeconds - _durationToleranceSeconds) {
      return false;
    }

    // Duration passing the checks above is NOT enough on its own —
    // billedMinutes/totalPointsDebited are computed by a separate step of
    // the backend's billing pipeline and can lag behind even once duration
    // itself is already correct (that's exactly what let a real 4-minute
    // call through with a correct duration but billedMinutes/points stuck
    // at 0 — this check never ran before, so it looked "finalized" and the
    // retry loop below was never even attempted). A call that ran long
    // enough to clear a full billable minute should have billedMinutes >= 1
    // in any reasonable billing scheme; if it doesn't, the billing step
    // hasn't finished, not "this call was free".
    if (s.duration >= 60 && s.billedMinutes <= 0) {
      return false;
    }

    return true;
  }

  Future<void> _resolveFinalSession(CallSessionEntity session) async {
    // Always show the best data already on hand immediately — never leave
    // the user staring at a loading skeleton for several seconds on the
    // hope that a retry will improve things. Confirmed in practice: some
    // backend calls have billedMinutes/totalPointsDebited permanently
    // stuck at 0 (a genuine server-side computation bug, not a timing
    // lag) — re-querying such a call doesn't help even once, let alone
    // over several seconds, so gating the entire display behind that wait
    // only made a real bug look like the popup wasn't showing anything.
    _emitFromSession(session);

    if (_looksFinalized(session)) return;

    appLogger.d(
      '⏳ [CallSummaryCubit] Session not finalized yet '
      '(duration=${session.duration}, billedMinutes=${session.billedMinutes}, '
      'totalPointsDebited=${session.totalPointsDebited}, '
      'localDurationSeconds=$_localDurationSeconds) — refining in the '
      'background; the numbers already shown will update only if a retry '
      'actually improves on them.',
    );

    const retryDelays = [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ];

    var latest = session;
    for (final delay in retryDelays) {
      await Future.delayed(delay);
      if (isClosed) return;

      final result = await _getCallDetailsUseCase(callId);
      if (isClosed) return;

      final refreshed = result.fold((_) => null, (s) => s);
      if (refreshed != null) {
        latest = refreshed;
        appLogger.d(
          '⏳ [CallSummaryCubit] Refetched call details: '
          'duration=${refreshed.duration}, billedMinutes=${refreshed.billedMinutes}, '
          'totalPointsDebited=${refreshed.totalPointsDebited}',
        );
        if (_looksFinalized(refreshed)) {
          _emitFromSession(refreshed);
          return;
        }
      }
    }

    appLogger.d(
      '⚠️ [CallSummaryCubit] Gave up waiting for the server to finalize '
      'billing for call $callId — showing the best data available '
      '(duration=${latest.duration}, billedMinutes=${latest.billedMinutes}, '
      'totalPointsDebited=${latest.totalPointsDebited}). If these are '
      'still wrong, the backend itself never finished computing them — '
      'this is not a timing issue.',
    );

    // A later refetch is still worth showing even if it never fully
    // "finalized" (e.g. duration corrected itself but billedMinutes stayed
    // stuck at 0 on every attempt) — but only if it actually differs from
    // what's already on screen, so a run of identical failed refetches
    // doesn't cause a pointless rebuild.
    if (!isClosed && latest != session) {
      _emitFromSession(latest);
    }
  }

  void _emitFromSession(CallSessionEntity session) {
    // The retries above gave the backend a real chance to catch up; if its
    // duration is still 0, or still implausibly lower than what this
    // device's own timer measured (the same check as _looksFinalized), show
    // the local value instead of a dishonest/wrong few-seconds number.
    // billedMinutes/totalPointsDebited still come from the server only,
    // since there's no local proxy for those.
    final serverDurationLooksWrong = _localDurationSeconds > 0 &&
        session.duration < _localDurationSeconds - _durationToleranceSeconds;
    final durationSeconds = (session.duration > 0 && !serverDurationLooksWrong)
        ? session.duration
        : (_localDurationSeconds > 0 ? _localDurationSeconds : session.duration);

    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    final durationText = minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';

    String title = '';
    String motivation = '';
    String talkLevel = '';
    Color levelColor = Colors.grey;

    if (isHost) {
      if (durationSeconds < 60) {
        title = "Session Completed";
        motivation = "Every conversation is a stepping stone. Keep talking to build deeper bonds!";
      } else if (durationSeconds < 300) {
        title = "Great Talk! 💬";
        motivation = "Fantastic conversation! Regular chats keep your followers engaged.";
      } else if (durationSeconds < 900) {
        title = "Wonderful Connection! 🌟";
        motivation = "Incredible session! You are building deep and valuable connections.";
      } else {
        title = "Elite Host Session! 🏆";
        motivation = "Masterclass conversation! Your dedication and presence are highly motivating.";
      }
      talkLevel = "Host Partner";
      levelColor = const Color(0xFF4A52DA); // Primary Color
    } else {
      if (durationSeconds < 60) {
        title = "Quick Connection";
        talkLevel = "Level 1: Quick Chat";
        levelColor = Colors.blue;
        motivation = "A warm introduction! A longer conversation opens up more to explore.";
      } else if (durationSeconds < 300) {
        title = "Friendly Connection";
        talkLevel = "Level 2: Friendly Talker";
        levelColor = Colors.teal;
        motivation = "Great connection! Thank you for supporting the host with a friendly chat.";
      } else if (durationSeconds < 900) {
        title = "Awesome Connection";
        talkLevel = "Level 3: Loyal Supporter";
        levelColor = Colors.purple;
        motivation = "Wonderful conversation! Your awesome support helps the host grow.";
      } else {
        title = "Deep Connection";
        talkLevel = "Level 4: Super Supporter";
        levelColor = Colors.amber;
        motivation = "Exceptional session! Your profound support makes a tremendous difference.";
      }
    }

    emit(CallSummaryState(
      isHost: isHost,
      title: title,
      motivationMessage: motivation,
      durationText: durationText,
      billedMinutes: session.billedMinutes,
      pointsValue: session.totalPointsDebited,
      pointsLabel: isHost ? "Points Earned" : "Points Spent",
      talkLevel: talkLevel,
      talkLevelColor: levelColor,
      isLoading: false,
    ));
  }
}
