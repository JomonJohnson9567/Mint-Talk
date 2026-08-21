import 'package:equatable/equatable.dart';
import '../../domain/entities/call_type.dart';

class IncomingCallPayloadDto extends Equatable {
  final String callId;
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final String hostId;
  final CallType callType;
  final String? agoraChannel;
  final String? agoraToken;

  const IncomingCallPayloadDto({
    required this.callId,
    required this.callerId,
    required this.callerName,
    this.callerAvatar,
    required this.hostId,
    required this.callType,
    this.agoraChannel,
    this.agoraToken,
  });

  factory IncomingCallPayloadDto.fromJson(Map<String, dynamic> json) {
    final rawType = (json['callType'] ?? json['call_type'] ?? json['type'])?.toString();
    return IncomingCallPayloadDto(
      callId: (json['callId'] ?? json['id'] ?? '').toString(),
      callerId: (json['callerId'] ?? json['caller_id'] ?? '').toString(),
      callerName:
          (json['callerName'] ?? json['caller_name'] ?? 'Incoming Caller')
              .toString(),
      callerAvatar: (json['callerAvatar'] ??
              json['caller_avatar'] ??
              json['callerAvatarUrl'] ??
              json['avatarUrl'])
          ?.toString(),
      hostId: (json['hostId'] ?? json['host_id'] ?? '').toString(),
      callType: CallType.fromString(rawType),
      agoraChannel: (json['agoraChannel'] ?? json['agora_channel'])?.toString(),
      agoraToken: (json['agoraToken'] ?? json['agora_token'])?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        callId,
        callerId,
        callerName,
        callerAvatar,
        hostId,
        callType,
        agoraChannel,
        agoraToken,
      ];
}
