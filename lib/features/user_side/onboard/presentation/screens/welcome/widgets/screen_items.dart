import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/transitions/utils/morphing_flight_shuttle.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/cubit/welcome/welcome_cubit.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/welcome/widgets/check_box.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/welcome/widgets/term_text.dart';

/// Terms card with the agreement checkbox, followed by "Get Started".
class ScreenItems extends StatelessWidget {
  const ScreenItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            // 1. Hero Background (Visual Only, no content that depends on Providers)
            Positioned.fill(
              child: Hero(
                tag: 'morphing_bottom_container',
                flightShuttleBuilder: morphingContainerFlightShuttleBuilder,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.cardWhite,
                        AppColors.greetingBanner.withAlpha(140),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: AppColors.profileDivider),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.plumDeep.withAlpha(12),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 2. The Content
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TermsText(),
                  SizedBox(height: 14.h),
                  const AgreeCheckboxRow(),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        BlocSelector<WelcomeCubit, WelcomeState, bool>(
          selector: (state) => state.isAgreed,
          builder: (context, isAgreed) {
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: isAgreed
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withAlpha(70),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: PrimaryButton(
                text: AppTexts.getStarted,
                height: 56.h,
                trailingIcon: Icons.arrow_forward_rounded,
                textStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
                disabledBackgroundColor: AppColors.primaryColor.withAlpha(110),
                disabledForegroundColor: AppColors.white,
                onPressed: isAgreed
                    ? () => Navigator.pushNamed(context, AppRoutes.phoneNumber)
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }
}
