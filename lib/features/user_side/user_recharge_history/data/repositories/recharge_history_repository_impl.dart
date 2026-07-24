import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/data/datasources/recharge_history_remote_datasource.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/domain/entities/recharge_history_item.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/domain/repositories/recharge_history_repository.dart';

@LazySingleton(as: RechargeHistoryRepository)
class RechargeHistoryRepositoryImpl implements RechargeHistoryRepository {
  final RechargeHistoryRemoteDataSource remoteDataSource;

  RechargeHistoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<RechargeHistoryItem>>> getRechargeHistory(
    String userId,
  ) async {
    try {
      final history = await remoteDataSource.getRechargeHistory(userId);
      return Right(history);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
