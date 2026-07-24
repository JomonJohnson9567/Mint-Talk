import 'package:dartz/dartz.dart';

import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/domain/entities/recharge_history_item.dart';

abstract class RechargeHistoryRepository {
  Future<Either<Failure, List<RechargeHistoryItem>>> getRechargeHistory(
    String userId,
  );
}
