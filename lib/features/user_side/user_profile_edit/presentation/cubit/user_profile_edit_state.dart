import 'package:equatable/equatable.dart';

enum UserProfileEditStatus { initial, loading, ready, saving, success, failure }

class UserProfileEditState extends Equatable {
  final UserProfileEditStatus status;
  final String fullName;
  final String phone;
  final String dob;
  final String gender;
  final String imagePath;
  final String termsAcceptedAt;
  final Map<String, String> fieldErrors;
  final String? errorMessage;

  const UserProfileEditState({
    this.status = UserProfileEditStatus.initial,
    this.fullName = '',
    this.phone = '',
    this.dob = '',
    this.gender = '',
    this.imagePath = '',
    this.termsAcceptedAt = '',
    this.fieldErrors = const {},
    this.errorMessage,
  });

  bool get isSaving => status == UserProfileEditStatus.saving;

  UserProfileEditState copyWith({
    UserProfileEditStatus? status,
    String? fullName,
    String? phone,
    String? dob,
    String? gender,
    String? imagePath,
    String? termsAcceptedAt,
    Map<String, String>? fieldErrors,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserProfileEditState(
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      imagePath: imagePath ?? this.imagePath,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    fullName,
    phone,
    dob,
    gender,
    imagePath,
    termsAcceptedAt,
    fieldErrors,
    errorMessage,
  ];
}
