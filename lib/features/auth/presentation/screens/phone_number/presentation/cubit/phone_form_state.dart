import 'package:equatable/equatable.dart';

enum PhoneFormStatus {
  initial,
  loading,
  otpSent,
  error,
  rateLimited,
}

class PhoneFormState extends Equatable {
  final String phoneNumber;
  final String? error;
  final bool isValid;
  final PhoneFormStatus status;
  final String? apiErrorMessage;

  const PhoneFormState({
    this.phoneNumber = '',
    this.error,
    this.isValid = false,
    this.status = PhoneFormStatus.initial,
    this.apiErrorMessage,
  });

  PhoneFormState copyWith({
    String? phoneNumber,
    String? Function()? error,
    bool? isValid,
    PhoneFormStatus? status,
    String? Function()? apiErrorMessage,
  }) {
    return PhoneFormState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      error: error != null ? error() : this.error,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      apiErrorMessage:
          apiErrorMessage != null ? apiErrorMessage() : this.apiErrorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [phoneNumber, error, isValid, status, apiErrorMessage];
}
