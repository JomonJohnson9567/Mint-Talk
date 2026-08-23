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
    // Shorter than the default 60s: this is retried by CallScreenCubit's
    // endCall(), so a stalled attempt should fail fast enough for that
    // retry to still happen while the user is watching, rather than leaving
    // the "ending…" button stuck for up to a minute.
    final response = await _apiClient.post(
      '/calls/$callId/cancel',
      requiresAuth: true,
      connectTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
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
    // See cancelCall above for why this overrides the default timeout.
    final response = await _apiClient.post(
      '/calls/$callId/end',
      requiresAuth: true,
      connectTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    );
    return CallSessionDto.fromJson(response);
  }

  @override
  Future<CallSessionDto> getCallDetails(String callId) async {
    // Also shortened: CallScreenCubit falls back to this call to reconcile
    // call state on both the ending party (endCall's awaitingRemoteConfirmation
    // branch) and the peer (_finalizeVoluntaryRemoteLeave, fired once Agora
    // reports the remote party left) — both are on the critical path for
    // actually ending the call on screen, so this must fail fast too rather
    // than inheriting the 60s default.
    final response = await _apiClient.get(
      '/calls/$callId',
      requiresAuth: true,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    );
    return CallSessionDto.fromJson(response);
  }
}
