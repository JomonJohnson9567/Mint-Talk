import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_call/animated_dots.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_status_text.dart';

/// Headline + supporting line under the mascot ("Calling Ananya…" /
/// "Waiting for your host to answer…"), with pulsing dots while the call
/// is still being set up.
class AudioCallStatusText extends StatelessWidget {
  final CallScreenState state;

  /// White text for the video screen, where it sits over the camera feed.
  final bool onDark;

  const AudioCallStatusText({
    super.key,
    required this.state,
    this.onDark = false,
  });

  bool get _isSettingUp =>
      state.status == CallScreenStatus.initial ||
      state.status == CallScreenStatus.initiating ||
      state.status == CallScreenStatus.ringing ||
      state.status == CallScreenStatus.connecting;

  bool get _hasConnectionIssue =>
      state.networkStatus.isLocalDeviceOffline ||
      state.networkStatus.isRemoteReconnecting ||
      state.mediaStatus == CallMediaStatus.reconnecting;

  /// Null while the call is active — the title is then the live timer,
  /// rendered by its own narrowly-scoped builder (see [_ActiveTimer]).
  String? get _title {
    if (state.isNoAnswer) return AppTexts.noAnswer;
    if (state.isCallEnded) return AppTexts.callEnded;
    if (state.status == CallScreenStatus.active) return null;
    if (state.status == CallScreenStatus.connecting) {
      return AppTexts.connectingEllipsis;
    }
    return '${AppTexts.calling} ${state.displayName}…';
  }

  String get _subtitle {
    if (state.isCallEnded) {
      if (state.errorMessage.isNotEmpty) return state.errorMessage;
      return state.isHost
          ? ''
          : '${AppTexts.tryReachingAgain} ${state.displayName} again?';
    }
    if (_hasConnectionIssue) return callStatusLabel(state);
    return switch (state.status) {
      CallScreenStatus.active =>
        '${AppTexts.connectedWith} ${state.displayName}',
      CallScreenStatus.connecting => callStatusLabel(state),
      _ => AppTexts.waitingForHostToAnswer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final title = _title;
    final subtitle = _subtitle;
    final titleStyle = TextStyle(
      fontSize: 24.csp,
      fontWeight: FontWeight.w800,
      color: onDark ? AppColors.white : AppColors.plumDeep,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Column(
        // Keyed on the phase (not the text) so the per-second timer and
        // media-status updates don't trigger a crossfade on every change.
        key: ValueKey(title ?? 'active'),
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: titleStyle,
            )
          else
            _ActiveTimer(style: titleStyle),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 6.cw),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.csp,
                fontWeight: FontWeight.w500,
                color: onDark
                    ? AppColors.white.withValues(alpha: 0.82)
                    : AppColors.plumMuted,
              ),
            ),
          ],
          SizedBox(height: 14.cw),
          // Reserves the dots' height in every phase so the layout doesn't
          // jump when they disappear on connect.
          SizedBox(
            height: 12.cw,
            child: _isSettingUp && !_hasConnectionIssue
                ? AnimatedDots(
                    color: onDark ? AppColors.white : AppColors.plumDeep,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

/// The parent builder skips duration-only ticks during a healthy active
/// call, so the timer listens to those ticks on its own.
class _ActiveTimer extends StatelessWidget {
  final TextStyle style;

  const _ActiveTimer({required this.style});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallScreenCubit, CallScreenState>(
      buildWhen: (previous, current) =>
          previous.durationSeconds != current.durationSeconds,
      builder: (context, state) => Text(
        formatCallDuration(state.durationSeconds),
        style: style.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
