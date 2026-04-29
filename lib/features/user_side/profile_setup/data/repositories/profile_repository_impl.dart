import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
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
      return Left(ValidationFailure(message: 'Validation failed', errors: e.errors));
    } on ServerException catch (e) {
      // In a real production app, we would parse field-level errors from the API response here
      // if the ApiClient didn't already do it, or if we want to add more context.
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyReferralCode(String referralCode) async {
    try {
      final result = await remoteDataSource.verifyReferralCode(referralCode);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
