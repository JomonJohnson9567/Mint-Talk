import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/network/api_client.dart';
import '../models/call_session_dto.dart';

abstract class ICallRemoteDataSource {
  Future<CallSessionDto> initiateCall({
    required String hostId,
    required String callType,
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
    required String callType,
  }) async {
    final response = await _apiClient.post(
      '/calls/initiate',
      body: {
        'hostId': hostId,
        'callType': callType,
      },
    );
    return CallSessionDto.fromJson(response);
  }

  @override
  Future<CallSessionDto> acceptCall(String callId) async {
    final response = await _apiClient.post('/calls/$callId/accept');
    return CallSessionDto.fromJson(response);
  }

  @override
  Future<CallSessionDto> rejectCall(String callId) async {
    final response = await _apiClient.post('/calls/$callId/reject');
    return CallSessionDto.fromJson(response);
  }

  @override
  Future<CallSessionDto> cancelCall(String callId) async {
    final response = await _apiClient.post('/calls/$callId/cancel');
    return CallSessionDto.fromJson(response);
  }

  @override
  Future<CallSessionDto> activateCall(String callId) async {
    final response = await _apiClient.post('/calls/$callId/activate');
    return CallSessionDto.fromJson(response);
  }

  @override
  Future<CallSessionDto> endCall(String callId) async {
    final response = await _apiClient.post('/calls/$callId/end');
    return CallSessionDto.fromJson(response);
  }

  @override
  Future<CallSessionDto> getCallDetails(String callId) async {
    final response = await _apiClient.get('/calls/$callId');
    return CallSessionDto.fromJson(response);
  }
}
