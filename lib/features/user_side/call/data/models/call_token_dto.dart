import 'package:mint_talk/core/utils/json_number_parser.dart';
import '../../domain/entities/call_token_entity.dart';

/// Parses POST /calls/:callId/token:
/// `data: { callId, agoraChannel, agoraUid, token, tokenExpiresInSeconds }`.
/// One legacy alias per field is kept for older backends.
class CallTokenDto {
  final String token;
  final String? channelName;
  final int? uid;
  final int? expiresInSeconds;

  const CallTokenDto({
    required this.token,
    this.channelName,
    this.uid,
    this.expiresInSeconds,
  });

  factory CallTokenDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    return CallTokenDto(
      token: (data['token'] ?? data['agoraToken'] ?? '').toString(),
      channelName: (data['agoraChannel'] ?? data['channelName'])?.toString(),
      uid: JsonNumberParser.parseInt(data['agoraUid'] ?? data['uid']),
      expiresInSeconds: JsonNumberParser.parseInt(
        data['tokenExpiresInSeconds'] ?? data['expiresInSeconds'],
      ),
    );
  }

  CallTokenEntity toEntity() => CallTokenEntity(
    token: token,
    channelName: channelName,
    uid: uid,
    expiresInSeconds: expiresInSeconds,
  );
}
