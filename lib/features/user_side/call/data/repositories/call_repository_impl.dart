import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/dio_failure_mapper.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import '../../domain/entities/call_session_entity.dart';
import '../../domain/entities/call_socket_event.dart';
import '../../domain/entities/call_type.dart';
import '../../domain/repositories/i_call_repository.dart';
import '../datasources/call_remote_data_source.dart';
import '../models/call_socket_event_dto.dart';

@LazySingleton(as: ICallRepository)
class CallRepositoryImpl implements ICallRepository {
  final ICallRemoteDataSource _remoteDataSource;
  final IPresenceSocketService _socketService;

  CallRepositoryImpl(this._remoteDataSource, this._socketService);

  // ---------------------------------------------------------------------------
  // Socket — typed stream exposed to domain layer
  // ---------------------------------------------------------------------------

  @override
  Stream<CallSocketEvent> get callSocketEvents {
    return _socketService.callStatusUpdates.map((json) {
      return CallSocketEventDto.fromJson(json).toEntity();
    });
  }

  @override
  void subscribeCallSocket(String callId) {
    _socketService.subscribeCall(callId);
  }

  @override
  void unsubscribeCallSocket(String callId) {
    _socketService.unsubscribeCall(callId);
  }

  // ---------------------------------------------------------------------------
  // HTTP REST — all state-changing actions
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, CallSessionEntity>> initiateCall({
    required String hostId,
    required CallType callType,
  }) async {
    try {
      final dto = await _remoteDataSource.initiateCall(
        hostId: hostId,
        callType: callType,
      );
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to initiate call'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CallSessionEntity>> acceptCall(String callId) async {
    try {
      final dto = await _remoteDataSource.acceptCall(callId);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to accept call'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CallSessionEntity>> rejectCall(String callId) async {
    try {
      final dto = await _remoteDataSource.rejectCall(callId);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to reject call'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CallSessionEntity>> cancelCall(String callId) async {
    try {
      final dto = await _remoteDataSource.cancelCall(callId);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to cancel call'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CallSessionEntity>> activateCall(String callId) async {
    try {
      final dto = await _remoteDataSource.activateCall(callId);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to activate call'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CallSessionEntity>> endCall(String callId) async {
    try {
      final dto = await _remoteDataSource.endCall(callId);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to end call'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CallSessionEntity>> getCallDetails(String callId) async {
    try {
      final dto = await _remoteDataSource.getCallDetails(callId);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to fetch call details'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

