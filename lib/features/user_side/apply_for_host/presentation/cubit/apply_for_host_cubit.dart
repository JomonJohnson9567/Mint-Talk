import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/utils/validators.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/value_objects/referral_code_value.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/host_application_entity.dart';
import '../../domain/repositories/host_application_repository.dart';
import '../../domain/usecases/submit_host_application_usecase.dart';
import '../../domain/usecases/upload_verification_photo_usecase.dart';
import 'apply_for_host_state.dart';

@injectable
class ApplyForHostCubit extends Cubit<ApplyForHostState> {
  final SubmitHostApplicationUseCase submitHostApplicationUseCase;
  final UploadVerificationPhotoUseCase uploadVerificationPhotoUseCase;
  final HostApplicationRepository repository;
  final AuthRepository authRepository;

  ApplyForHostCubit(
    this.submitHostApplicationUseCase,
    this.uploadVerificationPhotoUseCase,
    this.repository,
    this.authRepository,
  ) : super(const ApplyForHostState());

  Future<void> loadProfileData() async {
    emit(state.copyWith(status: ApplyForHostStatus.loading));
    try {
      final values = await Future.wait([
        authRepository.getFullName(),
        authRepository.getDob(),
      ]);
      if (isClosed) return;

      emit(
        state.copyWith(
          name: values[0]?.trim() ?? '',
          dob: values[1]?.trim() ?? '',
          status: ApplyForHostStatus.initial,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(status: ApplyForHostStatus.initial));
    }
  }

  void nameChanged(String value) {
    final errors = Map<String, String>.from(state.fieldErrors)..remove('name');
    emit(
      state.copyWith(
        name: value,
        fieldErrors: errors,
        status: ApplyForHostStatus.initial,
      ),
    );
  }

  void dobChanged(String value) {
    final errors = Map<String, String>.from(state.fieldErrors)..remove('dob');
    emit(
      state.copyWith(
        dob: value,
        fieldErrors: errors,
        status: ApplyForHostStatus.initial,
      ),
    );
  }

  void bioChanged(String value) {
    final errors = Map<String, String>.from(state.fieldErrors)..remove('bio');
    emit(
      state.copyWith(
        bio: value,
        fieldErrors: errors,
        status: ApplyForHostStatus.initial,
      ),
    );
  }

  void selfieChanged(String value) {
    final errors = Map<String, String>.from(state.fieldErrors)
      ..remove('selfie');
    emit(
      state.copyWith(
        selfiePath: value,
        // A new capture always invalidates the previous upload.
        verificationPhotoId: '',
        fieldErrors: errors,
        status: ApplyForHostStatus.initial,
      ),
    );
  }

  void referralCodeChanged(String value) {
    final errors = Map<String, String>.from(state.fieldErrors)
      ..remove('referralCode');
    emit(
      state.copyWith(
        referralCode: value.trim().toUpperCase(),
        referralStatus: ReferralCheck.idle,
        fieldErrors: errors,
        status: ApplyForHostStatus.initial,
      ),
    );
  }

  /// Mirrors the live verification result from `ReferralCubit`.
  void referralCheckChanged(ReferralCheck check) {
    if (state.referralCode.isEmpty) return;
    emit(state.copyWith(referralStatus: check));
  }

  Future<void> uploadSelfie(String path) async {
    if (path.isEmpty) return;
    emit(
      state.copyWith(
        isUploadingSelfie: true,
        status: ApplyForHostStatus.initial,
      ),
    );

    final result = await uploadVerificationPhotoUseCase(path);
    if (isClosed) return;

    // A retake replaced the photo while this upload was in flight — its
    // result belongs to a stale capture, so drop it.
    if (state.selfiePath != path) return;

    result.fold(
      (failure) {
        final errors = Map<String, String>.from(state.fieldErrors)
          ..['selfie'] = failure.message;
        emit(state.copyWith(isUploadingSelfie: false, fieldErrors: errors));
      },
      (photoId) {
        final errors = Map<String, String>.from(state.fieldErrors)
          ..remove('selfie');
        emit(
          state.copyWith(
            isUploadingSelfie: false,
            verificationPhotoId: photoId,
            fieldErrors: errors,
          ),
        );
      },
    );
  }

  void submit() async {
    final nameError = Validators.name(state.name);
    final dobError = Validators.dob(state.dob);
    final bioError = Validators.bio(state.bio);

    final errors = <String, String>{};
    if (nameError != null) errors['name'] = nameError;
    if (dobError != null) errors['dob'] = dobError;
    if (bioError != null) errors['bio'] = bioError;

    if (state.selfiePath.isEmpty || state.verificationPhotoId.isEmpty) {
      errors['selfie'] = state.isUploadingSelfie
          ? 'Selfie is still uploading...'
          : 'Selfie photo is required';
    }

    final referralError = _referralError();
    if (referralError != null) errors['referralCode'] = referralError;

    if (errors.isNotEmpty) {
      emit(
        state.copyWith(fieldErrors: errors, status: ApplyForHostStatus.initial),
      );
      return;
    }

    emit(state.copyWith(status: ApplyForHostStatus.submitting));

    final entity = HostApplicationEntity(
      name: state.name.trim(),
      dob: state.dob.trim(),
      bio: state.bio.trim(),
      verificationPhotoId: state.verificationPhotoId,
      referralCode: state.referralCode.isEmpty ? null : state.referralCode,
    );

    final result = await submitHostApplicationUseCase(entity);

    await result.fold<Future<void>>(
      (failure) async => emit(
        state.copyWith(
          status: ApplyForHostStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) async {
        try {
          await repository.markApplicationSubmitted();
        } catch (_) {
          // Application submitted remotely. Local cache exception ignored.
        }
        emit(state.copyWith(status: ApplyForHostStatus.success));
      },
    );
  }

  /// Referral code is optional; when entered it must be well-formed and
  /// verified by the live `/user/referral-verify` check before submitting.
  String? _referralError() {
    if (state.referralCode.isEmpty) return null;
    try {
      ReferralCodeValue(state.referralCode);
    } on ValidationException catch (e) {
      return e.errors['referralCode'] ?? AppTexts.invalidReferralCode;
    }
    return switch (state.referralStatus) {
      ReferralCheck.valid => null,
      ReferralCheck.invalid => AppTexts.invalidReferralCode,
      ReferralCheck.idle || ReferralCheck.checking => AppTexts.referralVerifying,
    };
  }
}
