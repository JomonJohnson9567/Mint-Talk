// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/otp_verification/presentation/cubit/otp_verification/otp_verification_cubit.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/otp_verification/presentation/widgets/otp_header.dart';
import 'package:mint_talk/core/transitions/utils/morphing_flight_shuttle.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/otp_verification/presentation/widgets/otp_input_row.dart';

class OtpBody extends StatelessWidget {
  const OtpBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpVerificationCubit, OtpVerificationState>(
      listener: (context, state) {
        if (state.status == OtpStatus.success) {
          Navigator.pushNamed(context, AppRoutes.success);
        }
      },
      builder: (context, state) {
        return Stack(
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
                        top: Radius.circular(30.r),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 2. The Content
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 15.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 80.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    const OtpHeader(),
                    SizedBox(height: 32.h),
                    const OtpInputRow(),
                    if (state.errorMessage != null) ...[
                      SizedBox(height: 10.h),
                      Center(
                        child: Text(
                          state.errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 14.sp),
                        ),
                      ),
                    ],
                    SizedBox(height: 32.h),
                    if (state.status == OtpStatus.submitting)
                      const Center(child: CircularProgressIndicator())
                    else
                      PrimaryButton(
                        text: AppTexts.verify,
                        onPressed: () {
                          context.read<OtpVerificationCubit>().submitOtp();
                        },
                      ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
