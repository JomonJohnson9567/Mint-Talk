// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/welcome/widgets/check_box.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/welcome/widgets/term_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/cubit/welcome/welcome_cubit.dart';
import 'package:mint_talk/core/transitions/utils/morphing_flight_shuttle.dart';

class ScreenItems extends StatelessWidget {
  const ScreenItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Hero Background (Visual Only, no content that depends on Providers)
        Positioned.fill(
          child: Hero(
            tag: 'morphing_bottom_container',
            flightShuttleBuilder: morphingContainerFlightShuttleBuilder,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.r),
                  topRight: Radius.circular(32.r),
                ),
              ),
            ),
          ),
        ),
        // 2. The Content
        Container(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 80.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              const TermsText(),
              SizedBox(height: 20.h),
              const AgreeCheckboxRow(),
              SizedBox(height: 24.h),
              BlocSelector<WelcomeCubit, WelcomeState, bool>(
                selector: (state) => state.isAgreed,
                builder: (context, isAgreed) {
                  return PrimaryButton(
                    onPressed: isAgreed
                        ? () {
                            Navigator.pushNamed(context, AppRoutes.phoneNumber);
                          }
                        : null,
                    text: AppTexts.getStarted,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
