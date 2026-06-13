import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../entities/host_application_entity.dart';

abstract class HostApplicationRepository {
  Future<Either<Failure, bool>> submitApplication(HostApplicationEntity application);
}
