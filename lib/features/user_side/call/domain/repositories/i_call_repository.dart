import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../entities/call_session_entity.dart';
import '../entities/call_socket_event.dart';
import '../entities/call_type.dart';

abstract class ICallRepository {
  /// Stream of real-time call status events pushed by the server via WebSocket.
  /// The Cubit subscribes to this stream to react to server-driven state changes
  /// (accepted, active, ended, rejected, missed, insufficient_balance).
  Stream<CallSocketEvent> get callSocketEvents;

  /// Subscribes the socket to receive events for the given [callId].
  void subscribeCallSocket(String callId);

  /// Unsubscribes the socket from events for the given [callId].
  void unsubscribeCallSocket(String callId);

  Future<Either<Failure, CallSessionEntity>> initiateCall({
    required String hostId,
    required CallType callType,
  });

  Future<Either<Failure, CallSessionEntity>> acceptCall(String callId);

  Future<Either<Failure, CallSessionEntity>> rejectCall(String callId);

  Future<Either<Failure, CallSessionEntity>> cancelCall(String callId);

  Future<Either<Failure, CallSessionEntity>> activateCall(String callId);

  Future<Either<Failure, CallSessionEntity>> endCall(String callId);

  Future<Either<Failure, CallSessionEntity>> getCallDetails(String callId);
}
