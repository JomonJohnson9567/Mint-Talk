import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../entities/host_wallet_entities.dart';

abstract class HostWalletRepository {
  Future<Either<Failure, HostWalletOverviewEntity>> getWalletOverview({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, HostWithdrawalEntryEntity>> requestWithdrawal(
    HostWithdrawalRequestParams request,
  );
}
