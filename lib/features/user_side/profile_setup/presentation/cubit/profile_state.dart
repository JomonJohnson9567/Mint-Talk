import 'package:equatable/equatable.dart';

enum ProfileFormStatus { initial, validating, valid, invalid }

enum ProfileSubmissionStatus { idle, submitting, success, error }

class ProfileState extends Equatable {
  final String name;
  final String dob;
  final String gender;
  final String? referralCode;
  final Map<String, String> fieldErrors;
  final ProfileFormStatus formStatus;
  final ProfileSubmissionStatus submissionStatus;
  final String? errorMessage;

  const ProfileState({
    this.name = '',
    this.dob = '',
    this.gender = '',
    this.referralCode,
    this.fieldErrors = const {},
    this.formStatus = ProfileFormStatus.initial,
    this.submissionStatus = ProfileSubmissionStatus.idle,
    this.errorMessage,
  });

  ProfileState copyWith({
    String? name,
    String? dob,
    String? gender,
    String? referralCode,
    Map<String, String>? fieldErrors,
    ProfileFormStatus? formStatus,
    ProfileSubmissionStatus? submissionStatus,
    String? errorMessage,
    bool clearErrors = false,
  }) {
    return ProfileState(
      name: name ?? this.name,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      referralCode: referralCode ?? this.referralCode,
      fieldErrors: clearErrors ? const {} : (fieldErrors ?? this.fieldErrors),
      formStatus: formStatus ?? this.formStatus,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        name,
        dob,
        gender,
        referralCode,
        fieldErrors,
        formStatus,
        submissionStatus,
        errorMessage,
      ];
}
