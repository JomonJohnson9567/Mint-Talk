import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/wallet/domain/entities/order_entity.dart';
import 'package:mint_talk/features/wallet/domain/entities/wallet_entity.dart';
import 'package:mint_talk/features/user_side/recharge_plans/data/models/recharge_plan_item.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletEntity>> initializeWallet();
  Future<Either<Failure, WalletEntity>> getWalletBalance(String userId);
  Future<Either<Failure, OrderEntity>> createOrder(String planId);
  Future<Either<Failure, int>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String transactionId,
  });
  Future<Either<Failure, List<RechargePlanItem>>> getPlans();
}
