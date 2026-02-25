import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:mint_talk/core/utils/validators.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/profile_setup_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  ProfileSetupCubit() : super(const ProfileSetupState());

  final formKey = GlobalKey<FormState>();

  void nameChanged(String name) {
    emit(state.copyWith(name: name));
  }

  void dobChanged(String dob) {
    emit(state.copyWith(dob: dob));
  }

  void genderChanged(String gender) {
    emit(state.copyWith(gender: gender, clearGenderError: true));
  }

  bool validateGender() {
    final error = Validators.gender(state.gender);
    if (error != null) {
      emit(state.copyWith(genderError: error));
      return false;
    }
    return true;
  }

  void submit() {
    emit(state.copyWith(autovalidateMode: AutovalidateMode.always));
    final isFormValid = formKey.currentState?.validate() ?? false;
    final isGenderValid = validateGender();

    if (isFormValid && isGenderValid) {
      emit(state.copyWith(status: ProfileSetupStatus.success));
    }
  }
}
