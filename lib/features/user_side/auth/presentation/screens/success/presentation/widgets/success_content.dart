import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/core/transitions/utils/morphing_flight_shuttle.dart';
import 'handle_bar.dart';
import 'success_icon.dart';

class SuccessContent extends StatelessWidget {
  const SuccessContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Stack(
        children: [
          // 1. Hero Background (Visual Only)
          Positioned.fill(
            child: Hero(
              tag: 'morphing_bottom_container',
              flightShuttleBuilder: morphingContainerFlightShuttleBuilder,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(50.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 2. The Content
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle Bar
                  const HandleBar(),

                  // Success Icon Circle
                  const SuccessIcon(),

                  Text(
                    AppTexts.verified,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  // SizedBox(height: 12.h),
                  Text(
                    AppTexts.yourNumberHasBeenVerifiedSuccessfully,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textGrey,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Setup Profile Button
                  PrimaryButton(
                    text: AppTexts.setupYourProfile,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.setupProfile);
                    },
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
