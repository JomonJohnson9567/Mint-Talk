import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/dio_failure_mapper.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/features/host_side/host_wallet/data/datasources/host_wallet_remote_datasource.dart';
import 'package:mint_talk/features/host_side/host_wallet/data/models/host_wallet_models.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_wallet_entities.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/repositories/host_wallet_repository.dart';

@LazySingleton(as: HostWalletRepository)
class HostWalletRepositoryImpl implements HostWalletRepository {
  final HostWalletRemoteDataSource remoteDataSource;

  HostWalletRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, HostWalletOverviewEntity>> getWalletOverview({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final model = await remoteDataSource.getWalletOverview(page: page, limit: limit);
      return Right(model);
    } on DioException catch (e, stackTrace) {
      appLogger.e(
        'HostWalletRepositoryImpl: request error loading wallet overview: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to load wallet overview'));
    } catch (e, stackTrace) {
      appLogger.e(
        'HostWalletRepositoryImpl: unknown error loading wallet overview: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, HostWithdrawalEntryEntity>> requestWithdrawal(
    HostWithdrawalRequestParams request,
  ) async {
    try {
      final model = await remoteDataSource.requestWithdrawal(
        HostWithdrawalRequestModel(
          amount: request.amount,
          payoutMethod: request.payoutMethod,
          bankName: request.bankName,
          accountNumber: request.accountNumber,
          ifsc: request.ifsc,
          holderName: request.holderName,
          upiId: request.upiId,
        ),
      );
      return Right(model);
    } on DioException catch (e, stackTrace) {
      appLogger.e(
        'HostWalletRepositoryImpl: request error submitting withdrawal: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to submit withdrawal request'));
    } catch (e, stackTrace) {
      appLogger.e(
        'HostWalletRepositoryImpl: unknown error submitting withdrawal: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
