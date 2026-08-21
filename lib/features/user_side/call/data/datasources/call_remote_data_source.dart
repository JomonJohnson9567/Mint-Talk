import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/network/api_client.dart';
import '../../domain/entities/call_type.dart';
import '../models/call_session_dto.dart';

abstract class ICallRemoteDataSource {
  Future<CallSessionDto> initiateCall({
    required String hostId,
    required CallType callType,
  });

  Future<CallSessionDto> acceptCall(String callId);

  Future<CallSessionDto> rejectCall(String callId);

  Future<CallSessionDto> cancelCall(String callId);

  Future<CallSessionDto> activateCall(String callId);

  Future<CallSessionDto> endCall(String callId);

  Future<CallSessionDto> getCallDetails(String callId);
}

@LazySingleton(as: ICallRemoteDataSource)
class CallRemoteDataSource implements ICallRemoteDataSource {
  final ApiClient _apiClient;

  CallRemoteDataSource(this._apiClient);

  @override
  Future<CallSessionDto> initiateCall({
    required String hostId,
    required CallType callType,
  }) async {
    final response = await _apiClient.post(
      '/calls/initiate',
      requiresAuth: true,
      body: {
        'hostId': hostId,
        'callType': callType.value,
      },
    );
    return CallSessionDto.fromJson(response);
  }

  @override
  Future<CallSessionDto> acceptCall(String callId) async {
    final response = await _apiClient.post(
      '/calls/$callId/accept',
      requiresAuth: true,
    );
    return CallSessionDto.fromJson(response);
  }

  @override
  Future<CallSessionDto> rejectCall(String callId) async {
    final response = await _apiClient.post(
      '/calls/$callId/reject',
      requiresAuth: true,
    );
    return CallSessionDto.fromJson(response);
  }

  @override
  Future<CallSessionDto> cancelCall(String callId) async {
    final response = await _apiClient.post(
      '/calls/$callId/cancel',
      requiresAuth: true,
    );
    return CallSessionDto.fromJson(response);
  }

  @override
  Future<CallSessionDto> activateCall(String callId) async {
    final response = await _apiClient.post(
      '/calls/$callId/activate',
      requiresAuth: true,
    );
    return CallSessionDto.fromJson(response);
  }

  @override
  Future<CallSessionDto> endCall(String callId) async {
    final response = await _apiClient.post(
      '/calls/$callId/end',
      requiresAuth: true,
    );
    return CallSessionDto.fromJson(response);
  }

  @override
  Future<CallSessionDto> getCallDetails(String callId) async {
    final response = await _apiClient.get(
      '/calls/$callId',
      requiresAuth: true,
    );
    return CallSessionDto.fromJson(response);
  }
}
