import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/entities/user_profile.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/usecases/update_user_profile.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/value_objects/dob.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/value_objects/full_name.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/value_objects/gender_value.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/value_objects/referral_code_value.dart';
import 'package:mint_talk/features/shared/profile/domain/usecases/upload_profile_image_usecase.dart';

import 'user_profile_edit_state.dart';

@injectable
class UserProfileEditCubit extends Cubit<UserProfileEditState> {
  final UpdateUserProfile _updateProfile;
  final AuthRepository _authRepository;
  final UploadProfileImageUseCase _uploadProfileImageUseCase;

  UserProfileEditCubit(
    this._updateProfile,
    this._authRepository,
    this._uploadProfileImageUseCase,
  ) : super(const UserProfileEditState());

  Future<void> loadProfile() async {
    emit(
      state.copyWith(status: UserProfileEditStatus.loading, clearError: true),
    );
    try {
      final values = await Future.wait<String?>([
        _authRepository.getFullName(),
        _authRepository.getPhone(),
        _authRepository.getDob(),
        _authRepository.getGender(),
        _authRepository.getProfileImagePath(),
        _authRepository.getTermsAcceptedAt(),
      ]);
      emit(
        state.copyWith(
          status: UserProfileEditStatus.ready,
          fullName: values[0] ?? '',
          phone: values[1] ?? '',
          dob: values[2] ?? '',
          gender: values[3] ?? '',
          imagePath: values[4] ?? '',
          termsAcceptedAt: values[5] ?? '',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: UserProfileEditStatus.failure,
          errorMessage: 'Unable to load your profile. Please try again.',
        ),
      );
    }
  }

  void fullNameChanged(String value) =>
      _change(fullName: value, field: 'fullName');
  void dobChanged(String value) => _change(dob: value, field: 'dob');
  void imageChanged(String value) => emit(state.copyWith(imagePath: value));

  void _change({String? fullName, String? dob, required String field}) {
    final errors = Map<String, String>.from(state.fieldErrors)..remove(field);
    emit(
      state.copyWith(
        status: UserProfileEditStatus.ready,
        fullName: fullName,
        dob: dob,
        fieldErrors: errors,
        clearError: true,
      ),
    );
  }

  Future<void> submit() async {
    if (state.isSaving) return;
    try {
      final profile = UserProfile(
        fullName: FullName(state.fullName),
        dob: DateOfBirth(state.dob),
        gender: GenderValue(state.gender),
        referralCode: ReferralCodeValue(null),
        termsAcceptedAt: state.termsAcceptedAt.isNotEmpty
            ? state.termsAcceptedAt
            : DateTime.now().toUtc().toIso8601String(),
      );
      emit(
        state.copyWith(
          status: UserProfileEditStatus.saving,
          fieldErrors: const {},
          clearError: true,
        ),
      );

      String finalImagePath = state.imagePath;
      if (state.imagePath.isNotEmpty &&
          !state.imagePath.startsWith('http') &&
          !state.imagePath.startsWith('/uploads/') &&
          File(state.imagePath).existsSync()) {
        final uploadResult = await _uploadProfileImageUseCase(
          UploadProfileImageParams(imagePath: state.imagePath),
        );
        final isFailure = uploadResult.fold(
          (failure) {
            emit(
              state.copyWith(
                status: UserProfileEditStatus.failure,
                errorMessage: failure.message,
              ),
            );
            return true;
          },
          (entity) {
            if (entity.avatarUrl.isNotEmpty) {
              finalImagePath = entity.avatarUrl;
            }
            return false;
          },
        );
        if (isFailure) return;
      }

      final result = await _updateProfile(profile);
      await result.fold(
        (failure) async => emit(
          state.copyWith(
            status: UserProfileEditStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (success) async {
          if (!success) {
            emit(
              state.copyWith(
                status: UserProfileEditStatus.failure,
                errorMessage: 'The server did not confirm the profile update.',
              ),
            );
            return;
          }
          await Future.wait([
            _authRepository.saveFullName(profile.fullName.value),
            _authRepository.saveDob(state.dob),
            _authRepository.saveProfileImagePath(finalImagePath),
          ]);
          emit(state.copyWith(status: UserProfileEditStatus.success));
        },
      );
    } on ValidationException catch (error) {
      emit(
        state.copyWith(
          status: UserProfileEditStatus.ready,
          fieldErrors: error.errors,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: UserProfileEditStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
