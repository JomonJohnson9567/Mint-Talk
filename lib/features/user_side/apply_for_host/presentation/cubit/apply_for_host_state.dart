import 'package:country_picker/country_picker.dart';
import 'package:equatable/equatable.dart';

enum ApplyForHostStatus { initial, submitting, success, failure }

class ApplyForHostState extends Equatable {
  final String name;
  final String bio;
  final String phone;
  final String dob;
  final Country selectedCountry;
  final ApplyForHostStatus status;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  const ApplyForHostState({
    this.name = '',
    this.bio = '',
    this.phone = '',
    this.dob = '',
    required this.selectedCountry,
    this.status = ApplyForHostStatus.initial,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  bool get isFormValid =>
      name.isNotEmpty &&
      bio.isNotEmpty &&
      phone.isNotEmpty &&
      dob.isNotEmpty &&
      fieldErrors.values.every((error) => error.isEmpty);

  ApplyForHostState copyWith({
    String? name,
    String? bio,
    String? phone,
    String? dob,
    Country? selectedCountry,
    ApplyForHostStatus? status,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return ApplyForHostState(
      name: name ?? this.name,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [
        name,
        bio,
        phone,
        dob,
        selectedCountry,
        status,
        errorMessage,
        fieldErrors,
      ];
}
