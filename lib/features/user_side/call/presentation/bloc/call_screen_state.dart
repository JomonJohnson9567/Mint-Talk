part of 'call_screen_cubit.dart';

enum CallScreenStatus {
  initial,
  initiating,
  ringing,
  connecting,
  active,
  ended,
  insufficientBalance,
  failed,
}

class CallScreenState extends Equatable {
  final CallScreenStatus status;
  final CallSessionEntity? session;
  final int durationSeconds;
  final bool isMuted;
  final bool isVideoMuted;
  final bool isSpeakerOn;
  final bool isRemoteUserJoined;
  final int? remoteUid;
  final String errorMessage;
  final int waveStep;

  const CallScreenState({
    this.status = CallScreenStatus.initial,
    this.session,
    this.durationSeconds = 0,
    this.isMuted = false,
    this.isVideoMuted = false,
    this.isSpeakerOn = false,
    this.isRemoteUserJoined = false,
    this.remoteUid,
    this.errorMessage = '',
    this.waveStep = 0,
  });

  bool get isCallActive => status == CallScreenStatus.active;
  bool get isCallEnded =>
      status == CallScreenStatus.ended ||
      status == CallScreenStatus.insufficientBalance ||
      status == CallScreenStatus.failed;

  CallScreenState copyWith({
    CallScreenStatus? status,
    CallSessionEntity? session,
    int? durationSeconds,
    bool? isMuted,
    bool? isVideoMuted,
    bool? isSpeakerOn,
    bool? isRemoteUserJoined,
    int? remoteUid,
    String? errorMessage,
    int? waveStep,
  }) {
    return CallScreenState(
      status: status ?? this.status,
      session: session ?? this.session,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isMuted: isMuted ?? this.isMuted,
      isVideoMuted: isVideoMuted ?? this.isVideoMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isRemoteUserJoined: isRemoteUserJoined ?? this.isRemoteUserJoined,
      remoteUid: remoteUid ?? this.remoteUid,
      errorMessage: errorMessage ?? this.errorMessage,
      waveStep: waveStep ?? this.waveStep,
    );
  }

  @override
  List<Object?> get props => [
        status,
        session,
        durationSeconds,
        isMuted,
        isVideoMuted,
        isSpeakerOn,
        isRemoteUserJoined,
        remoteUid,
        errorMessage,
        waveStep,
      ];
}
