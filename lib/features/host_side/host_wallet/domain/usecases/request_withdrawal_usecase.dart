import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../entities/host_wallet_entities.dart';
import '../repositories/host_wallet_repository.dart';

@injectable
class RequestWithdrawalUseCase
    implements UseCase<HostWithdrawalEntryEntity, HostWithdrawalRequestParams> {
  final HostWalletRepository repository;

  RequestWithdrawalUseCase(this.repository);

  @override
  Future<Either<Failure, HostWithdrawalEntryEntity>> call(
    HostWithdrawalRequestParams params,
  ) {
    return repository.requestWithdrawal(params);
  }
}
