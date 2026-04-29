import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/wallet/domain/entities/order_entity.dart';
import 'package:mint_talk/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateOrderUseCase {
  final WalletRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(String planId) async {
    return await repository.createOrder(planId);
  }
}
