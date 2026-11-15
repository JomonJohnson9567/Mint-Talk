import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';

/// The only chrome drawn over the video inside the system
/// picture-in-picture window: the running timer, plus a "you're muted"
/// hint. Plain logical sizes (not ScreenUtil-scaled) — the window is a
/// fraction of the screen and ScreenUtil would shrink text to illegible.
class PipCallOverlay extends StatelessWidget {
  const PipCallOverlay({super.key});

  static String _format(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 6,
      top: 6,
      child: BlocBuilder<CallScreenCubit, CallScreenState>(
        buildWhen: (previous, current) =>
            previous.durationSeconds != current.durationSeconds ||
            previous.isMuted != current.isMuted,
        builder: (context, state) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.isMuted) ...[
                    const Icon(
                      Icons.mic_off_rounded,
                      size: 11,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: 3),
                  ],
                  Text(
                    _format(state.durationSeconds),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
