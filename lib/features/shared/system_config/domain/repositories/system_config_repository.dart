import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/shared/system_config/domain/entities/system_config_entity.dart';

abstract class SystemConfigRepository {
  Future<Either<Failure, SystemConfigEntity>> getSystemConfig();
}
