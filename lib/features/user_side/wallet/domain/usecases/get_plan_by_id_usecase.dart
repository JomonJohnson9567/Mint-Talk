import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/user_side/recharge_plans/data/models/recharge_plan_item.dart';
import 'package:mint_talk/features/user_side/wallet/domain/repositories/wallet_repository.dart';

@injectable
class GetPlanByIdUseCase {
  final WalletRepository repository;

  GetPlanByIdUseCase(this.repository);

  Future<Either<Failure, RechargePlanItem>> call(String planId) async {
    return await repository.getPlanById(planId);
  }
}
