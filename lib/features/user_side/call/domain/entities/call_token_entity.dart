import 'package:equatable/equatable.dart';

/// RTC credentials from POST /calls/:callId/token — fetched by the caller
/// once the host accepts, and by both participants to renew before expiry.
class CallTokenEntity extends Equatable {
  final String token;
  final String? channelName;
  final int? uid;
  final int? expiresInSeconds;

  const CallTokenEntity({
    required this.token,
    this.channelName,
    this.uid,
    this.expiresInSeconds,
  });

  @override
  List<Object?> get props => [token, channelName, uid, expiresInSeconds];
}
