import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_controls.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_ended_controls.dart';

class CallScreenContents extends StatelessWidget {
  const CallScreenContents({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(flex: 2), // Top spacing
          // Profile Image
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withAlpha(128),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withAlpha(26),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60.r,
              backgroundImage: const AssetImage(AppAssets.maleIcon),
              backgroundColor: AppColors.lightGrey,
            ),
          ),
          SizedBox(height: 24.h),
          // User Name
          Text(
            "Anjli Singh",
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.h),
          // Status
          BlocBuilder<CallScreenCubit, CallScreenState>(
            builder: (context, state) {
              return Text(
                state is CallEnded ? "Call Ended" : "Calling...",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.callStatusText,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
          const Spacer(flex: 3), // Bottom spacing before buttons
          // Action Buttons
          BlocBuilder<CallScreenCubit, CallScreenState>(
            builder: (context, state) {
              if (state is CallEnded) {
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
    );
  }
}
