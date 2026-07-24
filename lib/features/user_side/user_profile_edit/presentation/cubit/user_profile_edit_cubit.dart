import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
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
  final AuthLocalDataSource _localDataSource;
  final UploadProfileImageUseCase _uploadProfileImageUseCase;

  UserProfileEditCubit(
    this._updateProfile,
    this._localDataSource,
    this._uploadProfileImageUseCase,
  ) : super(const UserProfileEditState());

  Future<void> loadProfile() async {
    emit(
      state.copyWith(status: UserProfileEditStatus.loading, clearError: true),
    );
    try {
      final values = await Future.wait<String?>([
        _localDataSource.getFullName(),
        _localDataSource.getPhone(),
        _localDataSource.getDob(),
        _localDataSource.getGender(),
        _localDataSource.getProfileImagePath(),
        _localDataSource.getTermsAcceptedAt(),
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
      if (state.imagePath.isNotEmpty && !state.imagePath.startsWith('http')) {
        final uploadResult = await _uploadProfileImageUseCase(
          UploadProfileImageParams(imagePath: state.imagePath),
        );
        uploadResult.fold(
          (_) {},
          (entity) {
            finalImagePath = entity.avatarUrl;
          },
        );
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
            _localDataSource.saveFullName(profile.fullName.value),
            _localDataSource.saveDob(state.dob),
            _localDataSource.saveProfileImagePath(finalImagePath),
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
