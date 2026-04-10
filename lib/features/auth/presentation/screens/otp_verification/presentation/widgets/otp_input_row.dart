import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/auth/presentation/screens/otp_verification/presentation/cubit/otp_verification/otp_verification_cubit.dart';
import 'package:mint_talk/features/auth/presentation/screens/otp_verification/presentation/widgets/otp_digit_field.dart';

class OtpInputRow extends StatelessWidget {
  const OtpInputRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpVerificationCubit, OtpVerificationState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.otpDigits != current.otpDigits ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        final cubit = context.read<OtpVerificationCubit>();
        final hasError =
            state.errorMessage != null && state.status != OtpStatus.resent;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(state.otpDigits.length, (index) {
            return OtpDigitField(
              controller: cubit.otpControllers[index],
              focusNode: cubit.otpFocusNodes[index],
              hasError: hasError,
              textInputAction: index == state.otpDigits.length - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              onChanged: (value) => cubit.otpChanged(index, value),
            );
          }),
        );
      },
    );
  }
}
