import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/host_profile_entity.dart';
import '../repositories/host_profile_repository.dart';

@injectable
class UpdateHostProfileUseCase implements UseCase<bool, HostProfileEntity> {
  final HostProfileRepository repository;

  UpdateHostProfileUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(HostProfileEntity params) {
    return repository.updateHostProfile(params);
  }
}
