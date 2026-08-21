import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../entities/host_target_entity.dart';

abstract class HostTargetsRepository {
  Future<Either<Failure, List<HostTargetEntity>>> getMyTargets();
}
