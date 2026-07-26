import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/utils/validators.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/host_application_entity.dart';
import '../../domain/usecases/submit_host_application_usecase.dart';
import '../../domain/usecases/upload_image_usecase.dart';
import '../../data/datasources/host_application_local_datasource.dart';
import 'apply_for_host_state.dart';

@injectable
class ApplyForHostCubit extends Cubit<ApplyForHostState> {
  final SubmitHostApplicationUseCase submitHostApplicationUseCase;
  final UploadImageUseCase uploadImageUseCase;
  final HostApplicationLocalDataSource localDataSource;
  final AuthLocalDataSource authLocalDataSource;

  ApplyForHostCubit(
    this.submitHostApplicationUseCase,
    this.uploadImageUseCase,
    this.localDataSource,
    this.authLocalDataSource,
  ) : super(const ApplyForHostState());

  Future<void> loadProfileData() async {
    emit(state.copyWith(status: ApplyForHostStatus.loading));
    try {
      final values = await Future.wait([
        authLocalDataSource.getFullName(),
        authLocalDataSource.getDob(),
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
        selfieUrl: value.isEmpty ? '' : state.selfieUrl,
        fieldErrors: errors,
        status: ApplyForHostStatus.initial,
      ),
    );
  }

  Future<void> uploadSelfie(String path) async {
    if (path.isEmpty) return;
    emit(
      state.copyWith(
        isUploadingSelfie: true,
        status: ApplyForHostStatus.initial,
      ),
    );

    final result = await uploadImageUseCase(path, 'selfieUrl');

    result.fold(
      (failure) {
        final errors = Map<String, String>.from(state.fieldErrors)
          ..['selfie'] = failure.message;
        emit(state.copyWith(isUploadingSelfie: false, fieldErrors: errors));
      },
      (url) {
        final errors = Map<String, String>.from(state.fieldErrors)
          ..remove('selfie');
        emit(
          state.copyWith(
            isUploadingSelfie: false,
            selfieUrl: url,
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

    if (state.selfiePath.isEmpty || state.selfieUrl.isEmpty) {
      errors['selfie'] = state.isUploadingSelfie
          ? 'Selfie is still uploading...'
          : 'Selfie photo is required';
    }

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
      selfieUrl: state.selfieUrl,
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
          await localDataSource.markApplicationSubmitted();
        } catch (_) {
          // Application submitted remotely. Local cache exception ignored.
        }
        emit(state.copyWith(status: ApplyForHostStatus.success));
      },
    );
  }
}
