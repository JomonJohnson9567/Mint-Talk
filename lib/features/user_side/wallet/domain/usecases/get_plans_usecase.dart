import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';
import 'package:mint_talk/features/user_side/wallet/domain/repositories/wallet_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetPlansUseCase implements UseCase<List<RechargePlanEntity>, NoParams> {
  final WalletRepository repository;

  GetPlansUseCase(this.repository);

  @override
  Future<Either<Failure, List<RechargePlanEntity>>> call(NoParams params) async {
    return await repository.getPlans();
  }
}
