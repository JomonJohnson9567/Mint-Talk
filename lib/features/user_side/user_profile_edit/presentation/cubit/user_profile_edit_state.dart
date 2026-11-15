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

  /// Values as loaded, so [hasChanges] can tell whether there's anything to
  /// save.
  final String initialFullName;
  final String initialImagePath;
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
    this.initialFullName = '',
    this.initialImagePath = '',
    this.fieldErrors = const {},
    this.errorMessage,
  });

  bool get isSaving => status == UserProfileEditStatus.saving;

  bool get hasChanges =>
      fullName.trim() != initialFullName.trim() ||
      imagePath != initialImagePath;

  UserProfileEditState copyWith({
    UserProfileEditStatus? status,
    String? fullName,
    String? phone,
    String? dob,
    String? gender,
    String? imagePath,
    String? termsAcceptedAt,
    String? initialFullName,
    String? initialImagePath,
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
      initialFullName: initialFullName ?? this.initialFullName,
      initialImagePath: initialImagePath ?? this.initialImagePath,
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
    initialFullName,
    initialImagePath,
    fieldErrors,
    errorMessage,
  ];
}
