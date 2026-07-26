import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../entities/call_session_entity.dart';

abstract class ICallRepository {
  Future<Either<Failure, CallSessionEntity>> initiateCall({
    required String hostId,
    required String callType,
  });

  Future<Either<Failure, CallSessionEntity>> acceptCall(String callId);

  Future<Either<Failure, CallSessionEntity>> rejectCall(String callId);

  Future<Either<Failure, CallSessionEntity>> cancelCall(String callId);

  Future<Either<Failure, CallSessionEntity>> activateCall(String callId);

  Future<Either<Failure, CallSessionEntity>> endCall(String callId);

  Future<Either<Failure, CallSessionEntity>> getCallDetails(String callId);
}
