import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      final model = await remoteDataSource.getUser(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(User user) async {
    try {
      await remoteDataSource.updateUser(user);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
