import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/dio_failure_mapper.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/user_side/profile_setup/data/datasources/profile_remote_data_source.dart';
import 'package:mint_talk/features/user_side/profile_setup/data/models/user_profile_model.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/entities/user_profile.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/repositories/profile_repository.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, bool>> createProfile(UserProfile profile) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      final result = await remoteDataSource.createProfile(model);
      return Right(result);
    } on ValidationException catch (e) {
      return Left(
        ValidationFailure(message: 'Validation failed', errors: e.errors),
      );
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to create profile'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateProfile(UserProfile profile) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      final result = await remoteDataSource.updateProfile(model);
      return Right(result);
    } on ValidationException catch (e) {
      return Left(
        ValidationFailure(message: 'Validation failed', errors: e.errors),
      );
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to update profile'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyReferralCode(String referralCode) async {
    try {
      final result = await remoteDataSource.verifyReferralCode(referralCode);
      return Right(result);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to verify referral code'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
