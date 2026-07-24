import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/block_repository.dart';

class BlockUserParams extends Equatable {
  final String userId;

  const BlockUserParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

@injectable
class BlockUserUseCase implements UseCase<Unit, BlockUserParams> {
  final BlockRepository repository;

  BlockUserUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(BlockUserParams params) {
    return repository.blockUser(params.userId);
  }
}
