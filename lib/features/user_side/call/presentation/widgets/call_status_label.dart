import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/transitions/widgets/animated_wave_text.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';

class CallStatusLabel extends StatelessWidget {
  final CallScreenState state;

  const CallStatusLabel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: state.isCallEnded
          ? AppColors.callEndedStatus
          : AppColors.callStatusText,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: state.isCallEnded
          ? Text(
              'Call Ended',
              key: const ValueKey('call-ended-label'),
              style: style,
            )
          : AnimatedWaveText(
              key: const ValueKey('calling-label'),
              text: 'Calling...',
              activeIndex: state.waveStep,
              style: style,
            ),
    );
  }
}
