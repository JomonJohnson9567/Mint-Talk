part of 'otp_verification_cubit.dart';

enum OtpStatus { initial, invalid, valid, submitting, success, failure }

class OtpVerificationState {
  final OtpStatus status;
  final List<String> otpDigits;
  final String? errorMessage;

  const OtpVerificationState({
    this.status = OtpStatus.initial,
    this.otpDigits = const ['', '', '', '', ''],
    this.errorMessage,
  });

  OtpVerificationState copyWith({
    OtpStatus? status,
    List<String>? otpDigits,
    String? errorMessage,
  }) {
    return OtpVerificationState(
      status: status ?? this.status,
      otpDigits: otpDigits ?? this.otpDigits,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
