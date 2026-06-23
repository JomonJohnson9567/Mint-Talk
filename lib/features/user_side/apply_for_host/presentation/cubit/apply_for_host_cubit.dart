import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:country_picker/country_picker.dart';
import 'package:mint_talk/core/utils/validators.dart';
import '../../domain/entities/host_application_entity.dart';
import '../../domain/usecases/submit_host_application_usecase.dart';
import '../../domain/usecases/upload_image_usecase.dart';
import 'apply_for_host_state.dart';

@injectable
class ApplyForHostCubit extends Cubit<ApplyForHostState> {
  final SubmitHostApplicationUseCase submitHostApplicationUseCase;
  final UploadImageUseCase uploadImageUseCase;

  ApplyForHostCubit(
    this.submitHostApplicationUseCase,
    this.uploadImageUseCase,
  ) : super(ApplyForHostState(selectedCountry: Country.parse('IN')));

  void nameChanged(String value) {
    final errors = Map<String, String>.from(state.fieldErrors)..remove('name');
    emit(state.copyWith(
      name: value,
      fieldErrors: errors,
      status: ApplyForHostStatus.initial,
    ));
  }

  void bioChanged(String value) {
    final errors = Map<String, String>.from(state.fieldErrors)..remove('bio');
    emit(state.copyWith(
      bio: value,
      fieldErrors: errors,
      status: ApplyForHostStatus.initial,
    ));
  }

  void phoneChanged(String value) {
    final errors = Map<String, String>.from(state.fieldErrors)..remove('phone');
    emit(state.copyWith(
      phone: value,
      fieldErrors: errors,
      status: ApplyForHostStatus.initial,
    ));
  }

  void countryChanged(Country country) {
    final errors = Map<String, String>.from(state.fieldErrors)..remove('phone');
    emit(state.copyWith(
      selectedCountry: country,
      fieldErrors: errors,
      status: ApplyForHostStatus.initial,
    ));
  }

  void dobChanged(String value) {
    final errors = Map<String, String>.from(state.fieldErrors)..remove('dob');
    emit(state.copyWith(
      dob: value,
      fieldErrors: errors,
      status: ApplyForHostStatus.initial,
    ));
  }

  void aadhaarNumberChanged(String value) {
    final errors = Map<String, String>.from(state.fieldErrors)..remove('aadhaarNumber');
    emit(state.copyWith(
      aadhaarNumber: value,
      fieldErrors: errors,
      status: ApplyForHostStatus.initial,
    ));
  }

  void aadhaarFrontChanged(String value) {
    final errors = Map<String, String>.from(state.fieldErrors)..remove('aadhaarFront');
    emit(state.copyWith(
      aadhaarFrontPath: value,
      aadhaarFrontUrl: value.isEmpty ? '' : state.aadhaarFrontUrl,
      fieldErrors: errors,
      status: ApplyForHostStatus.initial,
    ));
  }

  void aadhaarBackChanged(String value) {
    final errors = Map<String, String>.from(state.fieldErrors)..remove('aadhaarBack');
    emit(state.copyWith(
      aadhaarBackPath: value,
      aadhaarBackUrl: value.isEmpty ? '' : state.aadhaarBackUrl,
      fieldErrors: errors,
      status: ApplyForHostStatus.initial,
    ));
  }

  void selfieChanged(String value) {
    final errors = Map<String, String>.from(state.fieldErrors)..remove('selfie');
    emit(state.copyWith(
      selfiePath: value,
      selfieUrl: value.isEmpty ? '' : state.selfieUrl,
      fieldErrors: errors,
      status: ApplyForHostStatus.initial,
    ));
  }

  Future<void> uploadAadhaarFront(String path) async {
    if (path.isEmpty) return;
    emit(state.copyWith(
      isUploadingFront: true,
      status: ApplyForHostStatus.initial,
    ));

    final result = await uploadImageUseCase(path, 'frontPageUrl');

    result.fold(
      (failure) {
        final errors = Map<String, String>.from(state.fieldErrors)
          ..['aadhaarFront'] = failure.message;
        emit(state.copyWith(
          isUploadingFront: false,
          fieldErrors: errors,
        ));
      },
      (url) {
        final errors = Map<String, String>.from(state.fieldErrors)
          ..remove('aadhaarFront');
        emit(state.copyWith(
          isUploadingFront: false,
          aadhaarFrontUrl: url,
          fieldErrors: errors,
        ));
      },
    );
  }

  Future<void> uploadAadhaarBack(String path) async {
    if (path.isEmpty) return;
    emit(state.copyWith(
      isUploadingBack: true,
      status: ApplyForHostStatus.initial,
    ));

    final result = await uploadImageUseCase(path, 'backPageUrl');

    result.fold(
      (failure) {
        final errors = Map<String, String>.from(state.fieldErrors)
          ..['aadhaarBack'] = failure.message;
        emit(state.copyWith(
          isUploadingBack: false,
          fieldErrors: errors,
        ));
      },
      (url) {
        final errors = Map<String, String>.from(state.fieldErrors)
          ..remove('aadhaarBack');
        emit(state.copyWith(
          isUploadingBack: false,
          aadhaarBackUrl: url,
          fieldErrors: errors,
        ));
      },
    );
  }

  Future<void> uploadSelfie(String path) async {
    if (path.isEmpty) return;
    emit(state.copyWith(
      isUploadingSelfie: true,
      status: ApplyForHostStatus.initial,
    ));

    final result = await uploadImageUseCase(path, 'selfieUrl');

    result.fold(
      (failure) {
        final errors = Map<String, String>.from(state.fieldErrors)
          ..['selfie'] = failure.message;
        emit(state.copyWith(
          isUploadingSelfie: false,
          fieldErrors: errors,
        ));
      },
      (url) {
        final errors = Map<String, String>.from(state.fieldErrors)
          ..remove('selfie');
        emit(state.copyWith(
          isUploadingSelfie: false,
          selfieUrl: url,
          fieldErrors: errors,
        ));
      },
    );
  }

  void submit() async {
    final nameError = Validators.name(state.name);
    final bioError = Validators.bio(state.bio);
    final phoneError = Validators.phone(state.phone, countryCode: state.selectedCountry.countryCode);
    final dobError = Validators.dob(state.dob);
    final aadhaarError = Validators.aadhaar(state.aadhaarNumber);

    final errors = <String, String>{};
    if (nameError != null) errors['name'] = nameError;
    if (bioError != null) errors['bio'] = bioError;
    if (phoneError != null) errors['phone'] = phoneError;
    if (dobError != null) errors['dob'] = dobError;
    if (aadhaarError != null) errors['aadhaarNumber'] = aadhaarError;

    if (state.aadhaarFrontPath.isEmpty || state.aadhaarFrontUrl.isEmpty) {
      errors['aadhaarFront'] = state.isUploadingFront
          ? 'Front image is still uploading...'
          : 'Aadhaar front page image is required';
    }
    if (state.aadhaarBackPath.isEmpty || state.aadhaarBackUrl.isEmpty) {
      errors['aadhaarBack'] = state.isUploadingBack
          ? 'Back image is still uploading...'
          : 'Aadhaar back side image is required';
    }
    if (state.selfiePath.isEmpty || state.selfieUrl.isEmpty) {
      errors['selfie'] = state.isUploadingSelfie
          ? 'Selfie is still uploading...'
          : 'Selfie image is required';
    }

    if (errors.isNotEmpty) {
      emit(state.copyWith(
        fieldErrors: errors,
        status: ApplyForHostStatus.initial,
      ));
      return;
    }

    emit(state.copyWith(status: ApplyForHostStatus.submitting));

    final entity = HostApplicationEntity(
      name: state.name,
      bio: state.bio,
      phone: '+${state.selectedCountry.phoneCode}${state.phone}',
      dob: state.dob,
      aadhaarNumber: state.aadhaarNumber.replaceAll(RegExp(r'\s+'), ''),
      aadhaarFront: state.aadhaarFrontUrl,
      aadhaarBack: state.aadhaarBackUrl,
      selfie: state.selfieUrl,
    );

    final result = await submitHostApplicationUseCase(entity);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ApplyForHostStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: ApplyForHostStatus.success)),
    );
  }
}
