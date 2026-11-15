/// Turns the proximity sensor on or off, so the screen blanks (and ignores
/// touches) while the phone is held to the ear during an earpiece call.
///
/// Nothing here throws: a failure (or a device without a sensor) only
/// means the screen stays on, which can never break a call.
abstract interface class IProximityService {
  /// Idempotent — repeated calls with the same value are no-ops.
  Future<void> setEnabled(bool enabled);
}
