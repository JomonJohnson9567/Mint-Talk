enum CallParticipantRole {
  caller,
  host;

  /// Fixed Agora UIDs, scoped to the call's own channel: caller 1, host 2.
  int get agoraUid => switch (this) {
    CallParticipantRole.caller => 1,
    CallParticipantRole.host => 2,
  };

  /// The UID the other participant joins the channel with.
  int get peerAgoraUid => switch (this) {
    CallParticipantRole.caller => CallParticipantRole.host.agoraUid,
    CallParticipantRole.host => CallParticipantRole.caller.agoraUid,
  };
}
