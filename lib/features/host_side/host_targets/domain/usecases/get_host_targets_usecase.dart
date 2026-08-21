import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../entities/host_target_entity.dart';
import '../repositories/host_targets_repository.dart';

@injectable
class GetHostTargetsUseCase
    implements UseCase<List<HostTargetEntity>, NoParams> {
  final HostTargetsRepository repository;

  GetHostTargetsUseCase(this.repository);

  @override
  Future<Either<Failure, List<HostTargetEntity>>> call(NoParams params) {
    return repository.getMyTargets();
  }
}
