import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mint_talk/core/errors/dio_failure_mapper.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/user_side/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/order_entity.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/wallet_entity.dart';
import 'package:mint_talk/features/user_side/wallet/domain/repositories/wallet_repository.dart';

import 'package:injectable/injectable.dart';

@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, WalletEntity>> initializeWallet() async {
    try {
      final result = await remoteDataSource.initializeWallet();
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Wallet request failed'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> getWalletBalance(String userId) async {
    try {
      final result = await remoteDataSource.getWalletBalance(userId);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Wallet request failed'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder(String planId) async {
    try {
      final result = await remoteDataSource.createOrder(planId);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Wallet request failed'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RechargePlanEntity>> getPlanById(String planId) async {
    try {
      final result = await remoteDataSource.getPlanById(planId);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Wallet request failed'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String transactionId,
  }) async {
    try {
      final body = {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
        'transactionId': transactionId,
      };
      final result = await remoteDataSource.verifyPayment(body);
      return Right(result);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Wallet request failed'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RechargePlanEntity>>> getPlans() async {
    try {
      final result = await remoteDataSource.getPlans();
      return Right(result.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Wallet request failed'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
