import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../entities/host_application_entity.dart';
import '../repositories/host_application_repository.dart';

@injectable
class SubmitHostApplicationUseCase {
  final HostApplicationRepository repository;

  SubmitHostApplicationUseCase(this.repository);

  Future<Either<Failure, bool>> call(HostApplicationEntity application) async {
    return await repository.submitApplication(application);
  }
}
