import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/host_profile_entity.dart';

/// Repository interface for Host Profile operations.
abstract class HostProfileRepository {
  Future<Either<Failure, HostProfileEntity>> getHostProfile();
  Future<Either<Failure, bool>> updateHostProfile(HostProfileEntity profile);
}
