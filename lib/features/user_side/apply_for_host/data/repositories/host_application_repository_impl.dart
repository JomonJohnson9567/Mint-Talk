import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/dio_failure_mapper.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../../domain/entities/host_application_entity.dart';
import '../../domain/entities/host_application_status_entity.dart';
import '../../domain/repositories/host_application_repository.dart';
import '../datasources/host_application_local_datasource.dart';
import '../datasources/host_application_remote_datasource.dart';
import '../models/host_application_model.dart';

@LazySingleton(as: HostApplicationRepository)
class HostApplicationRepositoryImpl implements HostApplicationRepository {
  final HostApplicationRemoteDataSource remoteDataSource;
  final HostApplicationLocalDataSource localDataSource;

  HostApplicationRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, bool>> submitApplication(
    HostApplicationEntity application,
  ) async {
    try {
      final model = HostApplicationModel.fromEntity(application);
      final result = await remoteDataSource.submitApplication(model);
      return Right(result);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Host application request failed'));
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
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Host application request failed'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, HostApplicationStatusEntity>>
  getApplicationStatus() async {
    try {
      return Right(await remoteDataSource.getApplicationStatus());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Unable to load application status'));
    } catch (_) {
      return const Left(
        UnknownFailure(message: 'Unable to load application status'),
      );
    }
  }

  // ── Locally cached application flags ──────────────────────────────────

  @override
  Future<bool> hasAcceptedTerms() => localDataSource.hasAcceptedTerms();

  @override
  Future<void> acceptTerms() => localDataSource.acceptTerms();

  @override
  Future<bool> hasSubmittedApplication() => localDataSource.hasSubmittedApplication();

  @override
  Future<void> markApplicationSubmitted() => localDataSource.markApplicationSubmitted();
}
