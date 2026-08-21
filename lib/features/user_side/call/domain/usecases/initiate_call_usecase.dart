import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../entities/call_session_entity.dart';
import '../entities/call_type.dart';
import '../repositories/i_call_repository.dart';

class InitiateCallParams extends Equatable {
  final String hostId;
  final CallType callType;

  const InitiateCallParams({required this.hostId, required this.callType});

  @override
  List<Object?> get props => [hostId, callType];
}

@lazySingleton
class InitiateCallUseCase implements UseCase<CallSessionEntity, InitiateCallParams> {
  final ICallRepository repository;

  InitiateCallUseCase(this.repository);

  @override
  Future<Either<Failure, CallSessionEntity>> call(InitiateCallParams params) {
    return repository.initiateCall(
      hostId: params.hostId,
      callType: params.callType,
    );
  }
}
