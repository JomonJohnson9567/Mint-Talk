import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../entities/call_session_entity.dart';
import '../repositories/i_call_repository.dart';

@lazySingleton
class GetCallDetailsUseCase implements UseCase<CallSessionEntity, String> {
  final ICallRepository repository;

  GetCallDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, CallSessionEntity>> call(String callId) {
    return repository.getCallDetails(callId);
  }
}
