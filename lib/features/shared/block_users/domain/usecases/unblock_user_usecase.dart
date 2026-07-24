import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/block_repository.dart';

class UnblockUserParams extends Equatable {
  final String userId;

  const UnblockUserParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

@injectable
class UnblockUserUseCase implements UseCase<Unit, UnblockUserParams> {
  final BlockRepository repository;

  UnblockUserUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UnblockUserParams params) {
    return repository.unblockUser(params.userId);
  }
}
