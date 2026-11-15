/// Tracks the media milestones behind POST /calls/:callId/activate. Each
/// participant activates once its own media is up (joined the channel and
/// published local audio) — the backend pairs the two acknowledgements
/// (`accepted` → `active`), so the peer's state is not part of the gate.
/// The remote flags are kept for logging only. Billing is never activated
/// once [failed] is set.
class CallMediaReadiness {
  bool localJoined = false;
  bool localAudioPublished = false;
  bool remoteJoined = false;
  bool remoteAudioReceived = false;
  bool failed = false;

  bool get isReady => !failed && localJoined && localAudioPublished;

  /// Clears the media milestones (e.g. before a rejoin) but keeps [failed].
  void resetMedia() {
    localJoined = false;
    localAudioPublished = false;
    remoteJoined = false;
    remoteAudioReceived = false;
  }

  void reset() {
    resetMedia();
    failed = false;
  }

  @override
  String toString() =>
      'CallMediaReadiness(localJoined: $localJoined, '
      'localAudioPublished: $localAudioPublished, remoteJoined: $remoteJoined, '
      'remoteAudioReceived: $remoteAudioReceived, failed: $failed)';
}
