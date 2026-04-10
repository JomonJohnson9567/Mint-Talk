import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/utils/validators.dart';
import 'package:mint_talk/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:mint_talk/features/auth/presentation/screens/phone_number/presentation/cubit/phone_form_state.dart';
import 'package:mint_talk/features/auth/presentation/utils/auth_flow_helpers.dart';

@injectable
class PhoneFormCubit extends Cubit<PhoneFormState> {
  final SendOtpUseCase _sendOtpUseCase;

  PhoneFormCubit(this._sendOtpUseCase) : super(const PhoneFormState());

  void phoneNumberChanged(String value, {required String countryCode}) {
    if (value.isEmpty) {
      emit(
        state.copyWith(
          phoneNumber: value,
          error: () => null,
          isValid: false,
          status: PhoneFormStatus.initial,
        ),
      );
      return;
    }

    final error = Validators.phone(value, countryCode: countryCode);
    emit(
      state.copyWith(
        phoneNumber: value,
        error: () => error,
        isValid: error == null,
        status: PhoneFormStatus.initial,
      ),
    );
  }

  void validate({required String countryCode}) {
    final error = Validators.phone(state.phoneNumber, countryCode: countryCode);
    emit(state.copyWith(error: () => error, isValid: error == null));
  }

  /// Calls the SendOtp use case to send an OTP to the user's phone.
  Future<void> sendOtp({
    required String phone,
    required String countryCode,
  }) async {
    final normalizedPhone = AuthFlowHelpers.normalizePhone(phone);
    final normalizedCountryCode = AuthFlowHelpers.normalizeCountryCode(
      countryCode,
    );

    emit(state.copyWith(
      phoneNumber: normalizedPhone,
      status: PhoneFormStatus.loading,
      apiErrorMessage: () => null,
    ));

    final result = await _sendOtpUseCase(
      SendOtpParams(
        phone: normalizedPhone,
        countryCode: normalizedCountryCode,
      ),
    );

    result.fold(
      (failure) {
        if (failure is RateLimitFailure) {
          emit(state.copyWith(
            status: PhoneFormStatus.rateLimited,
            apiErrorMessage: () => AuthFlowHelpers.otpFailureMessage(failure),
          ));
        } else {
          emit(state.copyWith(
            status: PhoneFormStatus.error,
            apiErrorMessage: () => AuthFlowHelpers.otpFailureMessage(failure),
          ));
        }
      },
      (_) {
        emit(state.copyWith(status: PhoneFormStatus.otpSent));
      },
    );
  }

  /// Reset the status back to initial (e.g. after navigating away).
  void resetStatus() {
    emit(state.copyWith(
      status: PhoneFormStatus.initial,
      apiErrorMessage: () => null,
    ));
  }
}
