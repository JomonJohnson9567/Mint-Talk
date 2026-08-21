import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mint_talk/features/auth/domain/entities/auth_response_entity.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
///
/// Converts raw exceptions from [IAuthRemoteDataSource] into
/// domain-level [Failure] objects.
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;
  final IAuthLocalDataSource _localDataSource;
  final TokenManager _tokenManager;
  final IPresenceSocketService _presenceSocketService;

  const AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._tokenManager,
    this._presenceSocketService,
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
      await _localDataSource.saveProfileImagePath(result.user.avatarUrl);
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
      // Prevents a stale-identity socket from lingering if a different user
      // logs in within the same app session — the next login reconnects it.
      _presenceSocketService.disconnect();
    }
    return const Right(null);
  }

  // ── Cached profile field access ──────────────────────────────────────

  @override
  Future<String?> getUserId() => _localDataSource.getUserId();

  @override
  Future<String?> getFullName() => _localDataSource.getFullName();

  @override
  Future<String?> getPhone() => _localDataSource.getPhone();

  @override
  Future<String?> getDob() => _localDataSource.getDob();

  @override
  Future<String?> getGender() => _localDataSource.getGender();

  @override
  Future<String?> getRole() => _localDataSource.getRole();

  @override
  Future<String?> getProfileImagePath() => _localDataSource.getProfileImagePath();

  @override
  Future<String?> getReferralCode() => _localDataSource.getReferralCode();

  @override
  Future<String?> getTermsAcceptedAt() => _localDataSource.getTermsAcceptedAt();

  @override
  Future<int?> getAudioRate() => _localDataSource.getAudioRate();

  @override
  Future<int?> getVideoRate() => _localDataSource.getVideoRate();

  @override
  Future<bool?> getIsAudioAllowed() => _localDataSource.getIsAudioAllowed();

  @override
  Future<bool?> getIsVideoAllowed() => _localDataSource.getIsVideoAllowed();

  @override
  Future<void> saveFullName(String? fullName) => _localDataSource.saveFullName(fullName);

  @override
  Future<void> saveDob(String? dob) => _localDataSource.saveDob(dob);

  @override
  Future<void> saveGender(String? gender) => _localDataSource.saveGender(gender);

  @override
  Future<void> saveReferralCode(String? referralCode) =>
      _localDataSource.saveReferralCode(referralCode);

  @override
  Future<void> saveProfileImagePath(String? path) => _localDataSource.saveProfileImagePath(path);

  @override
  Future<void> saveAudioRate(int? rate) => _localDataSource.saveAudioRate(rate);

  @override
  Future<void> saveVideoRate(int? rate) => _localDataSource.saveVideoRate(rate);

  @override
  Future<void> saveIsAudioAllowed(bool? isAllowed) =>
      _localDataSource.saveIsAudioAllowed(isAllowed);

  @override
  Future<void> saveIsVideoAllowed(bool? isAllowed) =>
      _localDataSource.saveIsVideoAllowed(isAllowed);

  @override
  Future<void> saveIsProfileCompleted(bool isCompleted) =>
      _localDataSource.saveIsProfileCompleted(isCompleted);
}
