import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:mint_talk/core/utils/validators.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/profile_setup_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  final AuthLocalDataSource _localDataSource;

  ProfileSetupCubit(this._localDataSource) : super(const ProfileSetupState());

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

  Future<void> submit() async {
    emit(state.copyWith(autovalidateMode: AutovalidateMode.always));
    final isFormValid = formKey.currentState?.validate() ?? false;
    final isGenderValid = validateGender();

    if (isFormValid && isGenderValid) {
      // Typically, an API call would happen here.
      // After success, mark profile as completed locally.
      await _localDataSource.saveIsProfileCompleted(true);
      
      emit(state.copyWith(status: ProfileSetupStatus.success));
    }
  }
}
