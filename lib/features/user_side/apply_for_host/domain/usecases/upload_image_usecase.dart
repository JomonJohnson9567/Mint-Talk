import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../repositories/host_application_repository.dart';

@injectable
class UploadImageUseCase {
  final HostApplicationRepository repository;

  UploadImageUseCase(this.repository);

  Future<Either<Failure, String>> call(String imagePath, String key) async {
    return await repository.uploadImage(imagePath, key);
  }
}
