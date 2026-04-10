import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for the SendOtp use case.
class SendOtpParams {
  final String phone;
  final String countryCode;

  const SendOtpParams({required this.phone, required this.countryCode});
}

/// Sends an OTP to the user's phone number.
@injectable
class SendOtpUseCase {
  final AuthRepository _repository;

  const SendOtpUseCase(this._repository);

  Future<Either<Failure, void>> call(SendOtpParams params) {
    return _repository.sendOtp(
      phone: params.phone,
      countryCode: params.countryCode,
    );
  }
}
