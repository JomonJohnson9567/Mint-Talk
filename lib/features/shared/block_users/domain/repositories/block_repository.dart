import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/blocked_user_entity.dart';

abstract class BlockRepository {
  Future<Either<Failure, List<BlockedUserEntity>>> getBlockedList();
  Future<Either<Failure, Unit>> blockUser(String userId);
  Future<Either<Failure, Unit>> unblockUser(String userId);
}
