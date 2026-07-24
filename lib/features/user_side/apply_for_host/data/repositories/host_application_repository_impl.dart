import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../../domain/entities/host_application_entity.dart';
import '../../domain/entities/host_application_status_entity.dart';
import '../../domain/repositories/host_application_repository.dart';
import '../datasources/host_application_remote_datasource.dart';
import '../models/host_application_model.dart';

@LazySingleton(as: HostApplicationRepository)
class HostApplicationRepositoryImpl implements HostApplicationRepository {
  final HostApplicationRemoteDataSource remoteDataSource;

  HostApplicationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, bool>> submitApplication(
    HostApplicationEntity application,
  ) async {
    try {
      final model = HostApplicationModel.fromEntity(application);
      final result = await remoteDataSource.submitApplication(model);
      return Right(result);
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

  @override
  Future<Either<Failure, String>> uploadImage(
    String imagePath,
    String key,
  ) async {
    try {
      final result = await remoteDataSource.uploadImage(imagePath, key);
      return Right(result);
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

  @override
  Future<Either<Failure, HostApplicationStatusEntity>>
  getApplicationStatus() async {
    try {
      return Right(await remoteDataSource.getApplicationStatus());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(
        UnknownFailure(message: 'Unable to load application status'),
      );
    }
  }
}
