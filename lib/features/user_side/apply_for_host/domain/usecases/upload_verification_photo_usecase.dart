import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../repositories/host_application_repository.dart';

/// Uploads the applicant's live selfie to the private verification endpoint
/// and returns its `verificationPhotoId`. The photo is never public.
@injectable
class UploadVerificationPhotoUseCase {
  final HostApplicationRepository repository;

  UploadVerificationPhotoUseCase(this.repository);

  Future<Either<Failure, String>> call(String imagePath) {
    return repository.uploadVerificationPhoto(imagePath);
  }
}
