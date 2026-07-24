import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/profile_image_entity.dart';
import '../repositories/profile_repository.dart';

class UploadProfileImageParams extends Equatable {
  final String imagePath;

  const UploadProfileImageParams({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

@injectable
class UploadProfileImageUseCase implements UseCase<ProfileImageEntity, UploadProfileImageParams> {
  final ProfileRepository repository;

  UploadProfileImageUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileImageEntity>> call(UploadProfileImageParams params) {
    return repository.uploadProfileImage(params.imagePath);
  }
}
