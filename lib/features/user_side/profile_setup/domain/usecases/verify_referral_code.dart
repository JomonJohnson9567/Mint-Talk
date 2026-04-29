import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/repositories/profile_repository.dart';

@injectable
class VerifyReferralCode {
  final ProfileRepository repository;

  VerifyReferralCode(this.repository);

  Future<Either<Failure, bool>> call(String referralCode) {
    return repository.verifyReferralCode(referralCode);
  }
}
