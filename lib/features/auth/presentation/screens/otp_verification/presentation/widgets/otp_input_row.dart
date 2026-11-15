import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        final otpLength = state.otpDigits.length;
        // The next empty box, or the last one once the code is full.
        final activeIndex = state.otpCode.length.clamp(0, otpLength - 1);

        return Stack(
          children: [
            ListenableBuilder(
              listenable: cubit.otpFocusNode,
              builder: (context, _) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(otpLength, (index) {
                  return Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 14.w),
                    child: SizedBox(
                      width: 56.w,
                      child: OtpDigitField(
                        digit: state.otpDigits[index],
                        isActive:
                            cubit.otpFocusNode.hasFocus && index == activeIndex,
                        hasError: hasError,
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Invisible field over the boxes: it takes the taps, keyboard,
            // paste and SMS autofill, and backspace naturally deletes the
            // last digit.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                alwaysIncludeSemantics: true,
                child: TextField(
                  controller: cubit.otpController,
                  focusNode: cubit.otpFocusNode,
                  autofocus: true,
                  readOnly: state.status == OtpStatus.submitting,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: otpLength,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(otpLength),
                  ],
                  showCursor: false,
                  enableInteractiveSelection: false,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                  // Keep the caret at the end so typing always appends.
                  onTap: () =>
                      cubit.otpController.selection = TextSelection.collapsed(
                        offset: cubit.otpController.text.length,
                      ),
                  onChanged: cubit.otpChanged,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
