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
  /// (CallScreenState.durationSeconds) while it was active. Used only to
  /// pick the header's celebratory title/message tier immediately (so that
  /// cosmetic copy doesn't have to wait on the server), and to sanity-check
  /// whether a server-reported duration looks trustworthy enough to reveal
  /// — it is never itself shown as the Duration stat, which must only ever
  /// come from the server.
  final int _localDurationSeconds;

  /// Builds the header (title/motivation/talk level) immediately from
  /// whichever duration is known up front, and leaves the three numeric
  /// stats (duration/billedMinutes/points) as `null` — the dialog shows a
  /// skeleton in each of those slots until [_resolveStats] confirms real
  /// server data for it. Only real backend response values are ever shown
  /// in those slots — nothing is fabricated or substituted locally.
  CallSummaryCubit({
    required CallSessionEntity session,
    required this.isHost,
    int localDurationSeconds = 0,
    GetCallDetailsUseCase? getCallDetailsUseCase,
  })  : _getCallDetailsUseCase = getCallDetailsUseCase ?? getIt<GetCallDetailsUseCase>(),
        _localDurationSeconds = localDurationSeconds,
        callId = session.callId,
        super(_headerState(session: session, isHost: isHost, localDurationSeconds: localDurationSeconds)) {
    _resolveStats(session);
  }

  static const _durationToleranceSeconds = 10;
  static const _retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 3),
  ];

  /// A server duration is only worth showing once it's in the same
  /// ballpark as what this device itself measured second-by-second while
  /// the call was active. A 1-minute call whose /end response reports "7s"
  /// is not a finalized small value, it's the backend's billing
  /// computation returning an interim/partial number before it finished —
  /// worth one more retry rather than revealing it as-is.
  bool _durationLooksTrustworthy(CallSessionEntity s) {
    if (s.duration <= 0) return false;
    if (_localDurationSeconds > 0 &&
        s.duration < _localDurationSeconds - _durationToleranceSeconds) {
      return false;
    }
    return true;
  }

  /// billedMinutes/totalPointsDebited are computed by a separate step of
  /// the backend's billing pipeline and can arrive before or after
  /// duration does, independently. Any non-zero signal is real data worth
  /// showing immediately; a genuine zero can only be trusted once duration
  /// is itself confirmed short enough that "never billed a full minute" is
  /// a real answer rather than "not computed yet".
  bool _billingLooksTrustworthy(CallSessionEntity s) {
    if (s.billedMinutes > 0 || s.totalPointsDebited > 0) return true;
    return _durationLooksTrustworthy(s) && s.duration < 60;
  }

  Future<void> _resolveStats(CallSessionEntity initial) async {
    // Show whatever's already trustworthy immediately — never make a field
    // wait on a retry just because another field on the same response
    // isn't ready yet.
    _revealTrustworthyFields(initial);
    var latest = initial;

    for (final delay in _retryDelays) {
      if (state.durationText != null && state.billedMinutes != null) {
        return;
      }
      await Future.delayed(delay);
      if (isClosed) return;

      final result = await _getCallDetailsUseCase(callId);
      if (isClosed) return;

      final refreshed = result.fold((failure) {
        appLogger.d(
          '❌ [CallSummaryCubit] Failed to refresh call details: ${failure.message}',
        );
        return null;
      }, (s) => s);

      if (refreshed != null) {
        appLogger.d(
          '⏳ [CallSummaryCubit] Refetched call details: '
          'duration=${refreshed.duration}, billedMinutes=${refreshed.billedMinutes}, '
          'totalPointsDebited=${refreshed.totalPointsDebited}',
        );
        latest = refreshed;
        _revealTrustworthyFields(latest);
      }
    }

    if (isClosed) return;
    if (state.durationText != null && state.billedMinutes != null) return;

    // Retry window exhausted — this is still real response data, just not
    // data that passed the trustworthiness check above (a permanent
    // backend bug, not a timing lag). Reveal it as-is rather than leaving
    // the popup stuck on a skeleton forever.
    appLogger.d(
      '⚠️ [CallSummaryCubit] Gave up waiting for the server to finalize '
      'call $callId — revealing the last response as-is '
      '(duration=${latest.duration}, billedMinutes=${latest.billedMinutes}, '
      'totalPointsDebited=${latest.totalPointsDebited}).',
    );
    emit(
      state.copyWith(
        durationText: state.durationText ?? _formatDuration(latest.duration),
        billedMinutes: state.billedMinutes ?? latest.billedMinutes,
        pointsValue: state.pointsValue ?? latest.totalPointsDebited,
      ),
    );
  }

  /// Fills in whichever of the two stat groups (duration; billedMinutes +
  /// points) newly look trustworthy on [s] — [copyWith]'s `??` naturally
  /// leaves an already-resolved field alone, so this only ever moves a
  /// field from skeleton to shown, never back.
  void _revealTrustworthyFields(CallSessionEntity s) {
    final billingReady = _billingLooksTrustworthy(s);
    emit(
      state.copyWith(
        durationText: _durationLooksTrustworthy(s) ? _formatDuration(s.duration) : null,
        billedMinutes: billingReady ? s.billedMinutes : null,
        pointsValue: billingReady ? s.totalPointsDebited : null,
      ),
    );
  }

  static String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';
  }

  static CallSummaryState _headerState({
    required CallSessionEntity session,
    required bool isHost,
    required int localDurationSeconds,
  }) {
    // Decided once, up front, from whichever duration is known immediately
    // — purely to pick a celebratory copy tier, so the header never
    // flickers between retries the way a server-driven bucket would.
    final bucketSeconds = localDurationSeconds > 0 ? localDurationSeconds : session.duration;

    String title = '';
    String motivation = '';
    String talkLevel = '';
    Color levelColor = Colors.grey;

    if (isHost) {
      if (bucketSeconds < 60) {
        title = "Session Completed";
        motivation = "Every conversation is a stepping stone. Keep talking to build deeper bonds!";
      } else if (bucketSeconds < 300) {
        title = "Great Talk! 💬";
        motivation = "Fantastic conversation! Regular chats keep your followers engaged.";
      } else if (bucketSeconds < 900) {
        title = "Wonderful Connection! 🌟";
        motivation = "Incredible session! You are building deep and valuable connections.";
      } else {
        title = "Elite Host Session! 🏆";
        motivation = "Masterclass conversation! Your dedication and presence are highly motivating.";
      }
      talkLevel = "Host Partner";
      levelColor = const Color(0xFF4A52DA); // Primary Color
    } else {
      if (bucketSeconds < 60) {
        title = "Quick Connection";
        talkLevel = "Level 1: Quick Chat";
        levelColor = Colors.blue;
        motivation = "A warm introduction! A longer conversation opens up more to explore.";
      } else if (bucketSeconds < 300) {
        title = "Friendly Connection";
        talkLevel = "Level 2: Friendly Talker";
        levelColor = Colors.teal;
        motivation = "Great connection! Thank you for supporting the host with a friendly chat.";
      } else if (bucketSeconds < 900) {
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

    return CallSummaryState(
      isHost: isHost,
      title: title,
      motivationMessage: motivation,
      pointsLabel: isHost ? "Points Earned" : "Points Spent",
      talkLevel: talkLevel,
      talkLevelColor: levelColor,
      isLoading: false,
    );
  }
}
