import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/domain/entities/recharge_history_item.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/domain/repositories/recharge_history_repository.dart';

@injectable
class GetRechargeHistoryUseCase {
  final RechargeHistoryRepository repository;

  GetRechargeHistoryUseCase(this.repository);

  Future<Either<Failure, List<RechargeHistoryItem>>> call(String userId) {
    return repository.getRechargeHistory(userId);
  }
}
