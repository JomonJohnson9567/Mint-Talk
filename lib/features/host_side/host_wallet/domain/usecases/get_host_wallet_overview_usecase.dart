import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../entities/host_wallet_entities.dart';
import '../repositories/host_wallet_repository.dart';

@injectable
class GetHostWalletOverviewUseCase
    implements UseCase<HostWalletOverviewEntity, NoParams> {
  final HostWalletRepository repository;

  GetHostWalletOverviewUseCase(this.repository);

  @override
  Future<Either<Failure, HostWalletOverviewEntity>> call(NoParams params) {
    return repository.getWalletOverview();
  }
}
