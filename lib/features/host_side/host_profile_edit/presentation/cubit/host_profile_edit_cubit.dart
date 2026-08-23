import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';
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
      (profile) => emit(
        state.copyWith(
          status: HostProfileEditStatus.loaded,
          name: _cachedOrFallback(cachedValues[0], profile.fullName),
          phone: _cachedOrFallback(cachedValues[1], profile.phone),
          idNumber: _cachedOrFallback(cachedValues[2], profile.idNumber),
          dob: _cachedOrFallback(cachedValues[3], profile.dob),
          selectedCategories: profile.selectedCategories,
          avatarAsset: _cachedOrFallback(cachedValues[4], profile.avatarAsset),
        ),
      ),
    );
  }

  void nameChanged(String name) {
    emit(state.copyWith(name: name));
  }

  void dobChanged(String dob) {
    emit(state.copyWith(dob: dob));
  }

  void avatarChanged(String avatarAsset) {
    emit(state.copyWith(avatarAsset: avatarAsset));
  }

  void toggleCategory(String category) {
    final List<String> updatedCategories = List.from(state.selectedCategories);
    if (updatedCategories.contains(category)) {
      updatedCategories.remove(category);
    } else {
      if (updatedCategories.length < 4) {
        updatedCategories.add(category);
      }
    }
    emit(state.copyWith(selectedCategories: updatedCategories));
  }

  Future<void> submit() async {
    if (state.name.trim().isEmpty ||
        state.dob.isEmpty ||
        state.selectedCategories.isEmpty) {
      emit(state.copyWith(showErrors: true));
      return;
    }

    emit(state.copyWith(status: HostProfileEditStatus.saving));

    String finalAvatarAsset = state.avatarAsset;
    if (state.avatarAsset.isNotEmpty &&
        !state.avatarAsset.startsWith('http') &&
        !state.avatarAsset.startsWith('/uploads/') &&
        !state.avatarAsset.startsWith('assets/') &&
        File(state.avatarAsset).existsSync()) {
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
          if (entity.avatarUrl.isNotEmpty) {
            finalAvatarAsset = entity.avatarUrl;
          }
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

  String _cachedOrFallback(String? cached, String fallback) {
    final value = cached?.trim() ?? '';
    return value.isEmpty ? fallback : value;
  }
}
