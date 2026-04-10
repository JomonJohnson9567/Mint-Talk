import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/auth/domain/entities/auth_response_entity.dart';

/// Abstract contract for auth operations.
/// Implemented in the data layer by [AuthRepositoryImpl].
abstract class AuthRepository {
  /// Sends OTP to the given [phone] with [countryCode].
  Future<Either<Failure, void>> sendOtp({
    required String phone,
    required String countryCode,
  });

  /// Verifies the OTP entered by the user.
  /// Returns [AuthResponseEntity] containing user data and access token.
  Future<Either<Failure, AuthResponseEntity>> verifyOtp({
    required String phone,
    required String countryCode,
    required String otp,
  });

  /// Checks if the user has a valid stored refresh token.
  Future<Either<Failure, bool>> checkIsLoggedIn();

  /// Checks if the user has completed their profile setup.
  Future<Either<Failure, bool>> checkIsProfileComplete();

  /// Checks if the user has successfully completed OTP verification.
  Future<Either<Failure, bool>> checkIsOtpVerified();
}
