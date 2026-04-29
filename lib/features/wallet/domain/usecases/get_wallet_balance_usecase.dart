import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/wallet/domain/entities/wallet_entity.dart';
import 'package:mint_talk/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetWalletBalanceUseCase {
  final WalletRepository repository;

  GetWalletBalanceUseCase(this.repository);

  Future<Either<Failure, WalletEntity>> call(String userId) async {
    return await repository.getWalletBalance(userId);
  }
}
