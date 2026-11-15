/// Blocks OS-level screenshots and screen recording while at least one
/// holder needs it (e.g. the call screen, a live minimised call).
///
/// Holders are ref-counted by name, so independent owners can overlap —
/// protection stays on until the last one releases. Nothing here throws:
/// a platform failure only means capture stays allowed, which must never
/// break a call.
abstract interface class IScreenCaptureGuard {
  /// Idempotent per [holder].
  Future<void> acquire(String holder);

  /// Idempotent per [holder]; releasing an unknown holder is a no-op.
  Future<void> release(String holder);
}
