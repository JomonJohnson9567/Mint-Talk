import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
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
          final isProfileComplete =
              state.authResponse?.user.profileCompleted ?? false;
          final isStaff = state.authResponse?.user.role == 'staff';

          Navigator.pushNamedAndRemoveUntil(
            context,
            isProfileComplete
                ? isStaff
                      ? AppRoutes.hostMainNavigation
                      : AppRoutes.mainNavigation
                : AppRoutes.setupProfile,
            (route) => false,
          );
        } else if (state.status == OtpStatus.resent) {
          // Errors are shown inline under the code boxes, so only the
          // success confirmation needs a snackbar.
          _showSnackBar(
            context,
            message: 'A new code is on its way.',
            backgroundColor: Colors.green.shade700,
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == OtpStatus.submitting;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OtpHeader(phone: phone, countryCode: countryCode),
            SizedBox(height: 18.h),
            const OtpInputRow(),
            if (state.errorMessage != null &&
                state.status != OtpStatus.resent) ...[
              SizedBox(height: 8.h),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.red, fontSize: 12.sp),
              ),
            ],
            SizedBox(height: 14.h),
            Center(child: _buildResend(context, state)),
            SizedBox(height: 14.h),
            PrimaryButton(
              text: AppTexts.verifyAndContinue,
              height: 48.h,
              textStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              disabledBackgroundColor: AppColors.primaryColor.withValues(
                alpha: 0.22,
              ),
              disabledForegroundColor: AppColors.plumMuted,
              isLoading: isSubmitting,
              onPressed: state.isOtpComplete && !isSubmitting
                  ? () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      context.read<OtpVerificationCubit>().submitOtp(
                        phone: phone,
                        countryCode: countryCode,
                      );
                    }
                  : null,
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 14.sp,
                  color: AppColors.plumMuted,
                ),
                SizedBox(width: 5.w),
                Text(
                  AppTexts.numberStaysPrivate,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.plumMuted),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildResend(BuildContext context, OtpVerificationState state) {
    if (!state.canResend) {
      return Text(
        '${AppTexts.resendCodeIn} ${_formatCooldown(state.resendCooldown)}',
        style: TextStyle(
          fontSize: 13.sp,
          color: AppColors.plumMuted,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final isResending = state.status == OtpStatus.resending;

    // Compact so the layout doesn't jump when the countdown text is swapped
    // for this button.
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: isResending
          ? null
          : () => context.read<OtpVerificationCubit>().resendOtp(
              phone: phone,
              countryCode: countryCode,
            ),
      child: Text(
        isResending ? 'Resending...' : AppTexts.resendCode,
        style: TextStyle(
          fontSize: 13.sp,
          color: AppColors.plumDeep,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// 24 → "00:24"
  String _formatCooldown(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainder = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
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
