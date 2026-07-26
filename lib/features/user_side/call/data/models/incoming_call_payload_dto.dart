import 'package:equatable/equatable.dart';

class IncomingCallPayloadDto extends Equatable {
  final String callId;
  final String callerId;
  final String callerName;
  final String hostId;
  final String callType; // audio | video
  final String? agoraChannel;
  final String? agoraToken;

  const IncomingCallPayloadDto({
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.hostId,
    required this.callType,
    this.agoraChannel,
    this.agoraToken,
  });

  factory IncomingCallPayloadDto.fromJson(Map<String, dynamic> json) {
    return IncomingCallPayloadDto(
      callId: (json['callId'] ?? json['id'] ?? '').toString(),
      callerId: (json['callerId'] ?? json['caller_id'] ?? '').toString(),
      callerName:
          (json['callerName'] ?? json['caller_name'] ?? 'Incoming Caller')
              .toString(),
      hostId: (json['hostId'] ?? json['host_id'] ?? '').toString(),
      callType: (json['callType'] ?? json['call_type'] ?? 'audio').toString(),
      agoraChannel: (json['agoraChannel'] ?? json['agora_channel'])?.toString(),
      agoraToken: (json['agoraToken'] ?? json['agora_token'])?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        callId,
        callerId,
        callerName,
        hostId,
        callType,
        agoraChannel,
        agoraToken,
      ];
}
