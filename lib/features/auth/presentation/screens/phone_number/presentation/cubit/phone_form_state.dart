import 'package:equatable/equatable.dart';

class PhoneFormState extends Equatable {
  final String phoneNumber;
  final String? error;
  final bool isValid;

  const PhoneFormState({
    this.phoneNumber = '',
    this.error,
    this.isValid = false,
  });

  PhoneFormState copyWith({
    String? phoneNumber,
    String? Function()? error,
    bool? isValid,
  }) {
    return PhoneFormState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      error: error != null ? error() : this.error,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [phoneNumber, error, isValid];
}
