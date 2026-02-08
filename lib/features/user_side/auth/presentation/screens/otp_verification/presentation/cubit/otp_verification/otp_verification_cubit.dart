import 'package:bloc/bloc.dart';

import 'package:mint_talk/core/utils/validators.dart';

part 'otp_verification_state.dart';

class OtpVerificationCubit extends Cubit<OtpVerificationState> {
  OtpVerificationCubit() : super(OtpVerificationState());

  void otpChanged(int index, String value) {
    if (index < 0 || index >= 5) return;

    final updatedDigits = List<String>.from(state.otpDigits);
    updatedDigits[index] = value;

    emit(
      state.copyWith(
        otpDigits: updatedDigits,
        status: OtpStatus.initial,
        errorMessage: null,
      ),
    );
  }

  void submitOtp() {
    final otpCode = state.otpDigits.join();
    final error = Validators.otp(otpCode);

    if (error != null) {
      emit(state.copyWith(status: OtpStatus.invalid, errorMessage: error));
    } else {
      emit(state.copyWith(status: OtpStatus.submitting));
      // Simulate API call
      Future.delayed(const Duration(seconds: 1), () {
        emit(state.copyWith(status: OtpStatus.success));
      });
    }
  }
}
