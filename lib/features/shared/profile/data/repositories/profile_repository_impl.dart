import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/dio_failure_mapper.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/profile_image_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ProfileImageEntity>> uploadProfileImage(String imagePath) async {
    try {
      final dto = await remoteDataSource.uploadProfileImage(imagePath);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to upload profile image'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
