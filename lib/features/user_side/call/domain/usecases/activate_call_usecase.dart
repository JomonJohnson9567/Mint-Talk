import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../entities/call_session_entity.dart';
import '../repositories/i_call_repository.dart';

@lazySingleton
class ActivateCallUseCase implements UseCase<CallSessionEntity, String> {
  final ICallRepository repository;

  ActivateCallUseCase(this.repository);

  @override
  Future<Either<Failure, CallSessionEntity>> call(String callId) {
    return repository.activateCall(callId);
  }
}
