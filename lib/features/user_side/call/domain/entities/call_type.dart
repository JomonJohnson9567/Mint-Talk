enum CallType {
  audio,
  video;

  bool get isVideo => this == CallType.video;
  bool get isAudio => this == CallType.audio;

  String get value => name;

  static CallType fromString(String? raw) {
    if (raw == null) return CallType.audio;
    final normalized = raw.trim().toLowerCase();
    if (normalized == 'video' || normalized == 'video_call') {
      return CallType.video;
    }
    return CallType.audio;
  }
}
