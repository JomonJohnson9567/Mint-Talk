import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/entities/user_profile.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/usecases/create_user_profile.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/value_objects/dob.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/value_objects/full_name.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/value_objects/gender_value.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/value_objects/referral_code_value.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final CreateUserProfile _createUserProfile;
  final AuthLocalDataSource _localDataSource;

  ProfileCubit(
    this._createUserProfile,
    this._localDataSource,
  ) : super(const ProfileState());

  final formKey = GlobalKey<FormState>();

  void nameChanged(String name) {
    emit(state.copyWith(
      name: name,
      formStatus: ProfileFormStatus.initial,
      fieldErrors: Map.from(state.fieldErrors)..remove('fullName'),
    ));
  }

  void dobChanged(String dob) {
    emit(state.copyWith(
      dob: dob,
      formStatus: ProfileFormStatus.initial,
      fieldErrors: Map.from(state.fieldErrors)..remove('dob'),
    ));
  }

  void genderChanged(String gender) {
    emit(state.copyWith(
      gender: gender,
      formStatus: ProfileFormStatus.initial,
      fieldErrors: Map.from(state.fieldErrors)..remove('gender'),
    ));
  }

  void referralCodeChanged(String? code) {
    emit(state.copyWith(
      referralCode: code,
      fieldErrors: Map.from(state.fieldErrors)..remove('referralCode'),
    ));
  }

  Future<void> submit() async {
    emit(state.copyWith(
      formStatus: ProfileFormStatus.validating,
      submissionStatus: ProfileSubmissionStatus.idle,
      clearErrors: true,
    ));

    try {
      // 1. Domain Validation using Value Objects
      final fullNameVO = FullName(state.name);
      final dobVO = DateOfBirth(state.dob);
      final genderVO = GenderValue(state.gender);
      final referralVO = ReferralCodeValue(state.referralCode);

      final profile = UserProfile(
        fullName: fullNameVO,
        dob: dobVO,
        gender: genderVO,
        referralCode: referralVO,
        termsAcceptedAt: DateTime.now().toIso8601String(),
      );

      // 2. Submit to UseCase
      emit(state.copyWith(
        formStatus: ProfileFormStatus.valid,
        submissionStatus: ProfileSubmissionStatus.submitting,
      ));

      final result = await _createUserProfile(profile);

      result.fold(
        (failure) {
          final Map<String, String> fieldErrors = {};
          if (failure.message.contains('Validation')) {
            // If repository returned field errors (e.g. from API 400)
            // We would map them here. Assuming generic message for now.
            fieldErrors['general'] = failure.message;
          }
          
          emit(state.copyWith(
            submissionStatus: ProfileSubmissionStatus.error,
            errorMessage: failure.message,
            fieldErrors: fieldErrors,
          ));
        },
        (_) async {
          await _localDataSource.saveIsProfileCompleted(true);
          emit(state.copyWith(
            submissionStatus: ProfileSubmissionStatus.success,
          ));
        },
      );
    } on ValidationException catch (e) {
      // 3. Handle Domain Validation Errors
      emit(state.copyWith(
        formStatus: ProfileFormStatus.invalid,
        fieldErrors: e.errors,
      ));
    } catch (e) {
      emit(state.copyWith(
        submissionStatus: ProfileSubmissionStatus.error,
        errorMessage: 'An unexpected error occurred',
      ));
    }
  }
}
