import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, bool>> createProfile(UserProfile profile);
  Future<Either<Failure, bool>> verifyReferralCode(String referralCode);
}
