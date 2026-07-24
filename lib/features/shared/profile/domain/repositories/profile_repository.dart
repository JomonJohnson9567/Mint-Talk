import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/profile_image_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileImageEntity>> uploadProfileImage(String imagePath);
}
