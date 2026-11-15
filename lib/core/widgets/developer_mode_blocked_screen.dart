import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/cubit/developer_mode_cubit.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/custom_outline_button.dart';
import 'package:mint_talk/core/widgets/mint_talk_logo.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';

/// Replaces the whole app (navigator included — see `app.dart`'s
/// `_AppShell`) while [DeveloperModeCubit] reports Developer options on.
class DeveloperModeBlockedScreen extends StatelessWidget {
  const DeveloperModeBlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DeveloperModeCubit>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            children: [
              const Spacer(),
              const MintTalkLogo(),
              SizedBox(height: 40.h),
              Icon(
                Icons.developer_mode_rounded,
                color: AppColors.primaryColor,
                size: 40.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                'Developer options are on',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "For your security, MintTalk can't be used while Developer "
                'options are enabled on this device. Turn them off in '
                'Settings, then return to the app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.subtitleText,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Open settings',
                onPressed: cubit.openDeveloperSettings,
              ),
              SizedBox(height: 12.h),
              CustomOutlineButton(
                text: "I've turned it off",
                onPressed: cubit.check,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
