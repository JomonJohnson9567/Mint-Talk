import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/auth/domain/entities/auth_response_entity.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for the VerifyOtp use case.
class VerifyOtpParams {
  final String phone;
  final String countryCode;
  final String otp;

  const VerifyOtpParams({
    required this.phone,
    required this.countryCode,
    required this.otp,
  });
}

/// Verifies the OTP and returns user data + access token.
@injectable
class VerifyOtpUseCase {
  final AuthRepository _repository;

  const VerifyOtpUseCase(this._repository);

  Future<Either<Failure, AuthResponseEntity>> call(VerifyOtpParams params) {
    return _repository.verifyOtp(
      phone: params.phone,
      countryCode: params.countryCode,
      otp: params.otp,
    );
  }
}
