import 'package:mint_talk/core/services/agora/i_agora_service.dart';

/// Mute/speaker/camera toggle logic extracted out of [CallScreenCubit] —
/// self-contained (no `emit`/termination-state dependency), so it's safe to
/// own as a small collaborator rather than inline cubit methods.
class CallMediaControls {
  final IAgoraService _agoraService;

  const CallMediaControls(this._agoraService);

  bool toggleMuteAudio(bool currentlyMuted) {
    final next = !currentlyMuted;
    _agoraService.toggleMuteAudio(next);
    return next;
  }

  bool toggleMuteVideo(bool currentlyMuted) {
    final next = !currentlyMuted;
    _agoraService.toggleMuteVideo(next);
    return next;
  }

  bool toggleSpeakerphone(bool currentlySpeakerOn) {
    final next = !currentlySpeakerOn;
    _agoraService.toggleSpeakerphone(next);
    return next;
  }

  void switchCamera() => _agoraService.switchCamera();
}
