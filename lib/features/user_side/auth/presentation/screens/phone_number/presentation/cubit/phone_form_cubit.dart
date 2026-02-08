import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/utils/validators.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/phone_number/presentation/cubit/phone_form_state.dart';

class PhoneFormCubit extends Cubit<PhoneFormState> {
  PhoneFormCubit() : super(const PhoneFormState());

  void phoneNumberChanged(String value, {required String countryCode}) {
    if (value.isEmpty) {
      emit(
        state.copyWith(phoneNumber: value, error: () => null, isValid: false),
      );
      return;
    }

    final error = Validators.phone(value, countryCode: countryCode);
    emit(
      state.copyWith(
        phoneNumber: value,
        error: () => error,
        isValid: error == null,
      ),
    );
  }

  void validate({required String countryCode}) {
    final error = Validators.phone(state.phoneNumber, countryCode: countryCode);
    emit(state.copyWith(error: () => error, isValid: error == null));
  }
}
