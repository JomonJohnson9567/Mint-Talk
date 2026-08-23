import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/shared/system_config/domain/entities/system_config_entity.dart';
import 'package:mint_talk/features/shared/system_config/domain/repositories/system_config_repository.dart';

@injectable
class GetSystemConfigUseCase implements UseCase<SystemConfigEntity, NoParams> {
  final SystemConfigRepository repository;

  GetSystemConfigUseCase(this.repository);

  @override
  Future<Either<Failure, SystemConfigEntity>> call(NoParams params) async {
    return await repository.getSystemConfig();
  }
}
