import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/user_side/recharge_plans/data/models/recharge_plan_item.dart';
import 'package:mint_talk/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetPlansUseCase implements UseCase<List<RechargePlanItem>, NoParams> {
  final WalletRepository repository;

  GetPlansUseCase(this.repository);

  @override
  Future<Either<Failure, List<RechargePlanItem>>> call(NoParams params) async {
    return await repository.getPlans();
  }
}
