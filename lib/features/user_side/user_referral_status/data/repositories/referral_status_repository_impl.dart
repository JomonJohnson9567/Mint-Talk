import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:mint_talk/core/errors/dio_failure_mapper.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/user_side/user_referral_status/data/datasources/referral_status_remote_datasource.dart';
import 'package:mint_talk/features/user_side/user_referral_status/domain/entities/referral_status_entity.dart';
import 'package:mint_talk/features/user_side/user_referral_status/domain/repositories/referral_status_repository.dart';

@LazySingleton(as: ReferralStatusRepository)
class ReferralStatusRepositoryImpl implements ReferralStatusRepository {
  final ReferralStatusRemoteDataSource remoteDataSource;

  ReferralStatusRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ReferralStatusEntity?>> getReferralStatus(
    String userId,
  ) async {
    try {
      final result = await remoteDataSource.getReferralStatus(userId);
      return Right(result);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to fetch referral status'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
