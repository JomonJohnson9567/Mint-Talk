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
      await _remoteDataSource.sendOtp(
        phone: phone,
        countryCode: countryCode,
      );
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
      await _localDataSource.saveIsOtpVerified(true);
      await _localDataSource.saveIsProfileCompleted(result.user.profileCompleted);

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
  Future<Either<Failure, bool>> checkIsOtpVerified() async {
    try {
      final isVerified = await _localDataSource.getIsOtpVerified();
      return Right(isVerified);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to check OTP verification status: $e'));
    }
  }
}

