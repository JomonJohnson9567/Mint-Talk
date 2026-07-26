import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../../domain/entities/call_session_entity.dart';
import '../../domain/repositories/i_call_repository.dart';
import '../datasources/call_remote_data_source.dart';

@LazySingleton(as: ICallRepository)
class CallRepositoryImpl implements ICallRepository {
  final ICallRemoteDataSource _remoteDataSource;

  CallRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, CallSessionEntity>> initiateCall({
    required String hostId,
    required String callType,
  }) async {
    try {
      final dto = await _remoteDataSource.initiateCall(
        hostId: hostId,
        callType: callType,
      );
      return Right(dto.toEntity());
    } on DioException catch (e) {
      final message =
          e.response?.data is Map && e.response?.data['message'] != null
              ? e.response?.data['message'].toString()
              : 'Failed to initiate call';
      return Left(ServerFailure(message: message!));
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
      final message =
          e.response?.data is Map && e.response?.data['message'] != null
              ? e.response?.data['message'].toString()
              : 'Failed to accept call';
      return Left(ServerFailure(message: message!));
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
      final message =
          e.response?.data is Map && e.response?.data['message'] != null
              ? e.response?.data['message'].toString()
              : 'Failed to reject call';
      return Left(ServerFailure(message: message!));
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
      final message =
          e.response?.data is Map && e.response?.data['message'] != null
              ? e.response?.data['message'].toString()
              : 'Failed to cancel call';
      return Left(ServerFailure(message: message!));
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
      final message =
          e.response?.data is Map && e.response?.data['message'] != null
              ? e.response?.data['message'].toString()
              : 'Failed to activate call';
      return Left(ServerFailure(message: message!));
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
      final message =
          e.response?.data is Map && e.response?.data['message'] != null
              ? e.response?.data['message'].toString()
              : 'Failed to end call';
      return Left(ServerFailure(message: message!));
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
      final message =
          e.response?.data is Map && e.response?.data['message'] != null
              ? e.response?.data['message'].toString()
              : 'Failed to fetch call details';
      return Left(ServerFailure(message: message!));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
