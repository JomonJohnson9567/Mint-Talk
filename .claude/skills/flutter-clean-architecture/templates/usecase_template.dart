import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// One usecase = one action. Single `call()` method so it can be invoked
/// like a function: `await getUserUseCase(id)`.
@injectable
class GetUserUseCase {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  Future<Either<Failure, User>> call(String id) {
    return repository.getUser(id);
  }
}
