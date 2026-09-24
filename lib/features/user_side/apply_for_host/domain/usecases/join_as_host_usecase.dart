import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../repositories/host_application_repository.dart';

@injectable
class JoinAsHostUseCase {
  final HostApplicationRepository repository;

  const JoinAsHostUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.joinAsHost();
}
