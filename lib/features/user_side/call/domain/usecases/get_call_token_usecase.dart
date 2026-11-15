import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../entities/call_token_entity.dart';
import '../repositories/i_call_repository.dart';

@lazySingleton
class GetCallTokenUseCase implements UseCase<CallTokenEntity, String> {
  final ICallRepository repository;

  GetCallTokenUseCase(this.repository);

  @override
  Future<Either<Failure, CallTokenEntity>> call(String callId) {
    return repository.fetchCallToken(callId);
  }
}
