import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/entities/user_profile.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/repositories/profile_repository.dart';

@injectable
class CreateUserProfile {
  final ProfileRepository repository;

  CreateUserProfile(this.repository);

  Future<Either<Failure, bool>> call(UserProfile profile) {
    return repository.createProfile(profile);
  }
}
