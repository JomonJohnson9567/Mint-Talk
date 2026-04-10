part of 'otp_verification_cubit.dart';

enum OtpStatus {
  initial,
  invalid,
  valid,
  submitting,
  success,
  failure,
  resending,
  resent,
  rateLimited,
}

class OtpVerificationState extends Equatable {
  final OtpStatus status;
  final List<String> otpDigits;
  final String? errorMessage;
  final int resendCooldown;
  final AuthResponseEntity? authResponse;

  const OtpVerificationState({
    this.status = OtpStatus.initial,
    this.otpDigits = const ['', '', '', ''],
    this.errorMessage,
    this.resendCooldown = 0,
    this.authResponse,
  });

  bool get canResend => resendCooldown <= 0;

  bool get isOtpComplete => otpDigits.every((digit) => digit.isNotEmpty);

  String get otpCode => otpDigits.join();

  OtpVerificationState copyWith({
    OtpStatus? status,
    List<String>? otpDigits,
    String? Function()? errorMessage,
    int? resendCooldown,
    AuthResponseEntity? Function()? authResponse,
  }) {
    return OtpVerificationState(
      status: status ?? this.status,
      otpDigits: otpDigits ?? this.otpDigits,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      resendCooldown: resendCooldown ?? this.resendCooldown,
      authResponse: authResponse != null ? authResponse() : this.authResponse,
    );
  }

  @override
  List<Object?> get props => [
    status,
    otpDigits,
    errorMessage,
    resendCooldown,
    authResponse,
  ];
}
