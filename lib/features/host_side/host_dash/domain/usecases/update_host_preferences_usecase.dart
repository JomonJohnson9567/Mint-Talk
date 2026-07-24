import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../entities/host_preferences_entity.dart';
import '../repositories/host_dash_repository.dart';

@injectable
class UpdateHostPreferencesUseCase
    implements UseCase<HostPreferencesEntity, HostPreferencesEntity> {
  final HostDashRepository repository;

  UpdateHostPreferencesUseCase(this.repository);

  @override
  Future<Either<Failure, HostPreferencesEntity>> call(
    HostPreferencesEntity params,
  ) {
    return repository.updatePreferences(params);
  }
}
