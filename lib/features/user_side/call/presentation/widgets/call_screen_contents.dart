import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_controls.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_ended_controls.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_profile_avatar.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_status_label.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallScreenContents extends StatelessWidget {
  const CallScreenContents({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          children: [
            const Spacer(flex: 2),
            BlocSelector<CallScreenCubit, CallScreenState, bool>(
              selector: (state) => state.isBreathingExpanded,
              builder: (context, isBreathingExpanded) {
                return CallProfileAvatar(
                  imagePath: AppAssets.maleIcon,
                  isBreathingExpanded: isBreathingExpanded,
                );
              },
            ),
            SizedBox(height: 24.h),
            Text(
              'Anjli Singh',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8.h),
            BlocBuilder<CallScreenCubit, CallScreenState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status ||
                  previous.waveStep != current.waveStep,
              builder: (context, state) {
                return CallStatusLabel(state: state);
              },
            ),
            const Spacer(flex: 3),
            BlocSelector<CallScreenCubit, CallScreenState, CallScreenStatus>(
              selector: (state) => state.status,
              builder: (context, status) {
                if (status == CallScreenStatus.ended) {
                  return CallEndedControls(
                    onCancel: () {
                      Navigator.pop(context);
                    },
                    onCallAgain: () {
                      context.read<CallScreenCubit>().startCall();
                    },
                  );
                }

                return CallControls(
                  onEndCall: () {
                    context.read<CallScreenCubit>().endCall();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
