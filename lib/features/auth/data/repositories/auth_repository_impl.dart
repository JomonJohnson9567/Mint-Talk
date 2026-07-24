import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mint_talk/features/auth/domain/entities/auth_response_entity.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
///
/// Converts raw exceptions from [AuthRemoteDataSource] into
/// domain-level [Failure] objects.
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final TokenManager _tokenManager;

  const AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._tokenManager,
  );

  @override
  Future<Either<Failure, void>> sendOtp({
    required String phone,
    required String countryCode,
  }) async {
    try {
      await _remoteDataSource.sendOtp(phone: phone, countryCode: countryCode);
      return const Right(null);
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> verifyOtp({
    required String phone,
    required String countryCode,
    required String otp,
  }) async {
    try {
      final result = await _remoteDataSource.verifyOtp(
        phone: phone,
        countryCode: countryCode,
        otp: otp,
      );

      // Save status to local data source upon successful OTP verification
      await _localDataSource.saveUserId(result.user.id);
      await _localDataSource.saveRole(result.user.role);
      await _localDataSource.saveFullName(result.user.fullName);
      await _localDataSource.savePhone(result.user.phone);
      await _localDataSource.saveDob(_dobForDisplay(result.user.dob));
      await _localDataSource.saveGender(result.user.gender);
      await _localDataSource.saveReferralCode(result.user.referralCode);
      await _localDataSource.saveAudioRate(result.user.audioRate);
      await _localDataSource.saveVideoRate(result.user.videoRate);
      await _localDataSource.saveIsAudioAllowed(result.user.isAudioAllowed);
      await _localDataSource.saveIsVideoAllowed(result.user.isVideoAllowed);
      await _localDataSource.saveTermsAcceptedAt(result.user.termsAcceptedAt);
      await _localDataSource.saveIsOtpVerified(true);
      await _localDataSource.saveIsProfileCompleted(
        result.user.profileCompleted,
      );

      return Right(result);
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  String? _dobForDisplay(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(trimmed)) return trimmed;
    final parsed = DateTime.tryParse(trimmed);
    if (parsed == null) return trimmed;
    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day/$month/${parsed.year}';
  }

  @override
  Future<Either<Failure, bool>> checkIsLoggedIn() async {
    try {
      final isLoggedIn = await _tokenManager.hasRefreshToken();
      return Right(isLoggedIn);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to check token status: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkIsProfileComplete() async {
    try {
      final isComplete = await _localDataSource.getIsProfileCompleted();
      return Right(isComplete);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to check profile status: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getCachedUserRole() async {
    try {
      final role = await _localDataSource.getRole();
      return Right(role);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to check user role: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkIsOtpVerified() async {
    try {
      final isVerified = await _localDataSource.getIsOtpVerified();
      return Right(isVerified);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to check OTP verification status: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Remote session invalidate may fail if token is already expired or offline.
      // Suppress error so local storage cleanup proceeds without blocking logout.
    } finally {
      await _tokenManager.clearAll();
      await _localDataSource.clearAuthData();
    }
    return const Right(null);
  }
}
