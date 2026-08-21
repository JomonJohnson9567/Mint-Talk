import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';
import 'package:mint_talk/features/user_side/wallet/domain/repositories/wallet_repository.dart';

@injectable
class GetPlanByIdUseCase {
  final WalletRepository repository;

  GetPlanByIdUseCase(this.repository);

  Future<Either<Failure, RechargePlanEntity>> call(String planId) async {
    return await repository.getPlanById(planId);
  }
}
