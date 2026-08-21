import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/dio_failure_mapper.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/blocked_user_entity.dart';
import '../../domain/repositories/block_repository.dart';
import '../datasources/block_remote_data_source.dart';

@LazySingleton(as: BlockRepository)
class BlockRepositoryImpl implements BlockRepository {
  final BlockRemoteDataSource remoteDataSource;

  BlockRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<BlockedUserEntity>>> getBlockedList() async {
    try {
      final dtos = await remoteDataSource.getBlockedList();
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Right(entities);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Block-list request failed'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> blockUser(String userId) async {
    try {
      await remoteDataSource.blockUser(userId);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Block-list request failed'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> unblockUser(String userId) async {
    try {
      await remoteDataSource.unblockUser(userId);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Block-list request failed'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
