import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/host_profile_entity.dart';
import '../repositories/host_profile_repository.dart';

@injectable
class GetHostProfileUseCase implements UseCase<HostProfileEntity, NoParams> {
  final HostProfileRepository repository;

  GetHostProfileUseCase(this.repository);

  @override
  Future<Either<Failure, HostProfileEntity>> call(NoParams params) {
    return repository.getHostProfile();
  }
}
