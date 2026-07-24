import 'package:dartz/dartz.dart';

import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/user_side/user_referral_status/domain/entities/referral_status_entity.dart';

abstract class ReferralStatusRepository {
  Future<Either<Failure, ReferralStatusEntity?>> getReferralStatus(
    String userId,
  );
}
