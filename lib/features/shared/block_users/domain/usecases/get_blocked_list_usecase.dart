import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/blocked_user_entity.dart';
import '../repositories/block_repository.dart';

@injectable
class GetBlockedListUseCase implements UseCase<List<BlockedUserEntity>, NoParams> {
  final BlockRepository repository;

  GetBlockedListUseCase(this.repository);

  @override
  Future<Either<Failure, List<BlockedUserEntity>>> call(NoParams params) {
    return repository.getBlockedList();
  }
}
