import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import '../../domain/entities/call_session_entity.dart';
import '../../domain/usecases/get_call_details_usecase.dart';
import 'call_summary_state.dart';

class CallSummaryCubit extends Cubit<CallSummaryState> {
  final GetCallDetailsUseCase _getCallDetailsUseCase;
  final String callId;
  final bool isHost;

  CallSummaryCubit({
    required CallSessionEntity session,
    required this.isHost,
    GetCallDetailsUseCase? getCallDetailsUseCase,
  })  : _getCallDetailsUseCase = getCallDetailsUseCase ?? getIt<GetCallDetailsUseCase>(),
        callId = session.callId,
        super(CallSummaryState.loading(isHost: isHost)) {
    _fetchCallDetails();
  }

  Future<void> _fetchCallDetails() async {
    final result = await _getCallDetailsUseCase(callId);
    if (isClosed) return;

    result.fold(
      (failure) {
        emit(CallSummaryState.error(
          isHost: isHost,
          errorMessage: failure.message,
        ));
      },
      (session) {
        final durationSeconds = session.duration;
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
      },
    );
  }
}
