import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/otp_verification/presentation/cubit/otp_verification/otp_verification_cubit.dart';

class OtpInputRow extends StatelessWidget {
  const OtpInputRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpVerificationCubit, OtpVerificationState>(
      builder: (context, state) {
        final hasError = state.errorMessage != null;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            return Container(
              width: 50.w,
              height: 50.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: hasError
                      ? Colors.red
                      : AppColors.primaryPurple.withValues(alpha: 0.5),
                ),
              ),
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 16.sp, color: AppColors.black),
                onChanged: (value) {
                  context.read<OtpVerificationCubit>().otpChanged(index, value);
                  if (value.length == 1) {
                    if (index < 4) {
                      FocusScope.of(context).nextFocus();
                    } else {
                      FocusScope.of(context).unfocus();
                    }
                  }
                  if (value.isEmpty && index > 0) {
                    FocusScope.of(context).previousFocus();
                  }
                },
              ),
            );
          }),
        );
      },
    );
  }
}
