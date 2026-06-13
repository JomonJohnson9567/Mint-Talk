import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:country_picker/country_picker.dart';
import 'package:mint_talk/core/utils/validators.dart';
import '../../domain/entities/host_application_entity.dart';
import '../../domain/usecases/submit_host_application_usecase.dart';
import 'apply_for_host_state.dart';

@injectable
class ApplyForHostCubit extends Cubit<ApplyForHostState> {
  final SubmitHostApplicationUseCase submitHostApplicationUseCase;

  ApplyForHostCubit(this.submitHostApplicationUseCase)
      : super(ApplyForHostState(selectedCountry: Country.parse('IN')));

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

  void submit() async {
    final nameError = Validators.name(state.name);
    final bioError = Validators.bio(state.bio);
    final phoneError = Validators.phone(state.phone, countryCode: state.selectedCountry.countryCode);
    final dobError = Validators.dob(state.dob);

    final errors = <String, String>{};
    if (nameError != null) errors['name'] = nameError;
    if (bioError != null) errors['bio'] = bioError;
    if (phoneError != null) errors['phone'] = phoneError;
    if (dobError != null) errors['dob'] = dobError;

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
