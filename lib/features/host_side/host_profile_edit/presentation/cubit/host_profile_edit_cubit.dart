import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/value_objects/full_name.dart';
import 'package:mint_talk/features/shared/profile/domain/usecases/upload_profile_image_usecase.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../domain/entities/host_profile_entity.dart';
import '../../domain/usecases/get_host_profile_usecase.dart';
import '../../domain/usecases/update_host_profile_usecase.dart';
import 'host_profile_edit_state.dart';

@injectable
class HostProfileEditCubit extends Cubit<HostProfileEditState> {
  final GetHostProfileUseCase getProfileUseCase;
  final UpdateHostProfileUseCase updateProfileUseCase;
  final UploadProfileImageUseCase uploadProfileImageUseCase;
  final AuthRepository authRepository;

  HostProfileEditCubit({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.uploadProfileImageUseCase,
    required this.authRepository,
  }) : super(const HostProfileEditState());

  static const int maxCategories = 4;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: HostProfileEditStatus.loading));
    final cachedValues = await Future.wait<String?>([
      authRepository.getFullName(),
      authRepository.getPhone(),
      authRepository.getUserId(),
      authRepository.getDob(),
      authRepository.getProfileImagePath(),
      authRepository.getGender(),
      authRepository.getTermsAcceptedAt(),
    ]);
    final result = await getProfileUseCase(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HostProfileEditStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (profile) {
        final name = _cachedOrFallback(cachedValues[0], profile.fullName);
        final avatarAsset = _cachedOrFallback(
          cachedValues[4],
          profile.avatarAsset,
        );
        emit(
          state.copyWith(
            status: HostProfileEditStatus.loaded,
            name: name,
            phone: _cachedOrFallback(cachedValues[1], profile.phone),
            idNumber: _cachedOrFallback(cachedValues[2], profile.idNumber),
            dob: _cachedOrFallback(cachedValues[3], profile.dob),
            gender: _cachedOrFallback(cachedValues[5], profile.gender),
            selectedCategories: profile.selectedCategories,
            avatarAsset: avatarAsset,
            initialName: name,
            initialAvatarAsset: avatarAsset,
            initialCategories: profile.selectedCategories,
          ),
        );
      },
    );
  }

  void nameChanged(String value) {
    emit(state.copyWith(name: value, clearNameError: true));
  }

  void avatarChanged(String avatarAsset) {
    emit(state.copyWith(avatarAsset: avatarAsset));
  }

  void toggleCategory(String category) {
    final List<String> updatedCategories = List.from(state.selectedCategories);
    if (updatedCategories.contains(category)) {
      updatedCategories.remove(category);
    } else {
      if (updatedCategories.length < maxCategories) {
        updatedCategories.add(category);
      }
    }
    emit(state.copyWith(selectedCategories: updatedCategories));
  }

  Future<void> submit() async {
    if (state.isSaving) return;
    // Only the name is validated: DOB, phone, ID and gender are locked after
    // registration and categories are optional.
    try {
      FullName(state.name);
    } on ValidationException catch (e) {
      emit(state.copyWith(nameError: e.errors['fullName']));
      return;
    }
    emit(
      state.copyWith(
        status: HostProfileEditStatus.saving,
        clearNameError: true,
      ),
    );

    String finalAvatarAsset = state.avatarAsset;
    if (_needsUpload(state.avatarAsset)) {
      final uploadResult = await uploadProfileImageUseCase(
        UploadProfileImageParams(imagePath: state.avatarAsset),
      );
      final isFailure = uploadResult.fold(
        (failure) {
          emit(
            state.copyWith(
              status: HostProfileEditStatus.failure,
              errorMessage: failure.message,
            ),
          );
          return true;
        },
        (entity) {
          // Never fall back to the local/asset path: the backend drops
          // non-URL values, so users would see no avatar.
          if (entity.avatarUrl.isEmpty) {
            emit(
              state.copyWith(
                status: HostProfileEditStatus.failure,
                errorMessage: "Couldn't save photo, please try again",
              ),
            );
            return true;
          }
          finalAvatarAsset = entity.avatarUrl;
          return false;
        },
      );
      if (isFailure) return;
    }

    final genderVal = await authRepository.getGender();
    final termsVal = await authRepository.getTermsAcceptedAt();

    final profile = HostProfileEntity(
      id: state.idNumber,
      fullName: state.name.trim(),
      phone: state.phone,
      idNumber: state.idNumber,
      dob: state.dob,
      gender: (genderVal ?? '').trim().isEmpty ? 'female' : genderVal!,
      termsAcceptedAt: (termsVal ?? '').trim().isEmpty
          ? DateTime.now().toUtc().toIso8601String()
          : termsVal!,
      selectedCategories: state.selectedCategories,
      avatarAsset: finalAvatarAsset,
    );

    final result = await updateProfileUseCase(profile);
    await result.fold<Future<void>>(
      (failure) async {
        emit(
          state.copyWith(
            status: HostProfileEditStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) async {
        await Future.wait([
          authRepository.saveFullName(profile.fullName),
          authRepository.saveDob(profile.dob),
          authRepository.saveProfileImagePath(profile.avatarAsset),
        ]);
        if (isClosed) return;
        emit(state.copyWith(status: HostProfileEditStatus.success));
      },
    );
  }

  /// Preset avatars (bundled `assets/`) and picked/captured files must be
  /// uploaded; server URLs (`http…`, `/uploads/…`) are already stored.
  bool _needsUpload(String path) {
    if (path.isEmpty) return false;
    if (path.startsWith('http') || path.startsWith('/uploads/')) return false;
    if (path.startsWith('assets/')) return true;
    return File(path).existsSync();
  }

  String _cachedOrFallback(String? cached, String fallback) {
    final value = cached?.trim() ?? '';
    return value.isEmpty ? fallback : value;
  }
}
