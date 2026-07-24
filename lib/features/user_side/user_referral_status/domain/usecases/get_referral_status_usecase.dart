import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/user_side/user_referral_status/domain/entities/referral_status_entity.dart';
import 'package:mint_talk/features/user_side/user_referral_status/domain/repositories/referral_status_repository.dart';

@injectable
class GetReferralStatusUseCase
    implements UseCase<ReferralStatusEntity?, String> {
  final ReferralStatusRepository repository;

  GetReferralStatusUseCase(this.repository);

  @override
  Future<Either<Failure, ReferralStatusEntity?>> call(String userId) {
    return repository.getReferralStatus(userId);
  }
}
