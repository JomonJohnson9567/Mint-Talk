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

  /// Fetches the current user from the backend and refreshes the cached
  /// role and host call rates, called on every app launch so the
  /// launch-time UI reflects reality instead of possibly-stale cached
  /// values (e.g. a host application approved while the app was closed).
  /// Returns the role. Falls back to the previously cached role if the
  /// fetch fails (offline, or a transient server error) rather than
  /// blocking launch.
  Future<Either<Failure, String?>> syncCurrentUser();

  /// Checks if the user has successfully completed OTP verification.
  Future<Either<Failure, bool>> checkIsOtpVerified();

  /// Logs out the current user and clears local auth session on success.
  Future<Either<Failure, void>> logout();

  // ── Cached profile field access ──────────────────────────────────────
  //
  // Plain pass-through reads/writes over the locally cached auth/profile
  // fields. These intentionally do NOT return `Either<Failure, T>` — a
  // secure-storage cache read/write has no meaningful failure mode worth
  // propagating to callers (a missing key already just resolves to `null`).

  Future<String?> getUserId();
  Future<String?> getFullName();
  Future<String?> getPhone();
  Future<String?> getDob();
  Future<String?> getGender();
  Future<String?> getRole();
  Future<String?> getProfileImagePath();
  Future<String?> getReferralCode();
  Future<String?> getTermsAcceptedAt();
  Future<int?> getAudioRate();
  Future<int?> getVideoRate();
  Future<bool?> getIsAudioAllowed();
  Future<bool?> getIsVideoAllowed();

  Future<void> saveFullName(String? fullName);
  Future<void> saveDob(String? dob);
  Future<void> saveGender(String? gender);
  Future<void> saveReferralCode(String? referralCode);
  Future<void> saveProfileImagePath(String? path);
  Future<void> saveAudioRate(int? rate);
  Future<void> saveVideoRate(int? rate);
  Future<void> saveIsAudioAllowed(bool? isAllowed);
  Future<void> saveIsVideoAllowed(bool? isAllowed);
  Future<void> saveIsProfileCompleted(bool isCompleted);
}
