import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user.dart';

/// Abstract contract — lives in domain, implemented in data.
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
  Future<Either<Failure, void>> updateUser(User user);
}
