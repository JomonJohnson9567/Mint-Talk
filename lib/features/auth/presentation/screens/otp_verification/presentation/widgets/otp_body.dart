// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/transitions/utils/morphing_flight_shuttle.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/auth/presentation/screens/otp_verification/presentation/cubit/otp_verification/otp_verification_cubit.dart';
import 'package:mint_talk/features/auth/presentation/screens/otp_verification/presentation/widgets/otp_header.dart';
import 'package:mint_talk/features/auth/presentation/screens/otp_verification/presentation/widgets/otp_input_row.dart';

class OtpBody extends StatelessWidget {
  final String phone;
  final String countryCode;

  const OtpBody({super.key, required this.phone, required this.countryCode});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpVerificationCubit, OtpVerificationState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == OtpStatus.success) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.success,
            (route) => false,
          );
        } else if (state.status == OtpStatus.failure) {
          _showSnackBar(
            context,
            message: state.errorMessage ?? 'Verification failed',
            backgroundColor: Colors.red.shade700,
          );
        } else if (state.status == OtpStatus.rateLimited) {
          _showSnackBar(
            context,
            message: state.errorMessage ?? 'Too many attempts. Please wait.',
            backgroundColor: Colors.orange.shade700,
          );
        } else if (state.status == OtpStatus.resent) {
          _showSnackBar(
            context,
            message: 'OTP resent successfully',
            backgroundColor: Colors.green.shade700,
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
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
                    OtpHeader(phone: phone, countryCode: countryCode),
                    SizedBox(height: 32.h),
                    const OtpInputRow(),
                    if (state.errorMessage != null &&
                        state.status != OtpStatus.resent) ...[
                      SizedBox(height: 10.h),
                      Center(
                        child: Text(
                          state.errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 14.sp),
                        ),
                      ),
                    ],
                    SizedBox(height: 16.h),
                    Center(
                      child: state.canResend
                          ? TextButton(
                              onPressed: state.status == OtpStatus.resending
                                  ? null
                                  : () {
                                      context
                                          .read<OtpVerificationCubit>()
                                          .resendOtp(
                                            phone: phone,
                                            countryCode: countryCode,
                                          );
                                    },
                              child: Text(
                                state.status == OtpStatus.resending
                                    ? 'Resending...'
                                    : 'Resend OTP',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : Text(
                              'Resend OTP in ${state.resendCooldown}s',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 14.sp,
                              ),
                            ),
                    ),
                    SizedBox(height: 24.h),
                    if (state.status == OtpStatus.submitting)
                      const Center(child: CircularProgressIndicator())
                    else
                      PrimaryButton(
                        text: AppTexts.verify,
                        onPressed: state.isOtpComplete
                            ? () {
                                context.read<OtpVerificationCubit>().submitOtp(
                                  phone: phone,
                                  countryCode: countryCode,
                                );
                              }
                            : null,
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

  void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }
}
