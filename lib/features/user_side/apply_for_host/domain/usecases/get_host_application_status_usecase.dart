import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../entities/host_application_status_entity.dart';
import '../repositories/host_application_repository.dart';

@injectable
class GetHostApplicationStatusUseCase {
  final HostApplicationRepository repository;

  const GetHostApplicationStatusUseCase(this.repository);

  Future<Either<Failure, HostApplicationStatusEntity>> call() =>
      repository.getApplicationStatus();
}
