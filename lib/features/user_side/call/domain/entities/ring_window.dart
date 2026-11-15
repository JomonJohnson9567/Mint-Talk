/// How long a ringing call has left, from the server's `ringExpiresAt`.
///
/// Both the caller's no-answer timer and the host's incoming overlay use
/// this, for audio and video alike, so the two sides close together and in
/// step with the server.
abstract final class RingWindow {
  /// Used when the server didn't send `ringExpiresAt`.
  static const Duration fallback = Duration(seconds: 20);

  /// A deadline further out than this is treated as bad data (or a badly
  /// skewed clock) and replaced by the fallback, so a call can't ring on
  /// indefinitely.
  static const Duration maxWindow = Duration(seconds: 90);

  /// Time left until [ringExpiresAt], measured against [serverNow] (pass
  /// `ServerClock.now()`, never the raw device clock). Zero when it has
  /// already passed — e.g. a push delivered late.
  static Duration remaining(
    DateTime? ringExpiresAt,
    DateTime serverNow, {
    Duration fallback = RingWindow.fallback,
  }) {
    if (ringExpiresAt == null) return fallback;
    final left = ringExpiresAt.difference(serverNow);
    if (left.isNegative) return Duration.zero;
    if (left > maxWindow) return fallback;
    return left;
  }
}
