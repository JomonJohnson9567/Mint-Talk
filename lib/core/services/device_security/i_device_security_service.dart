/// Device-level security checks that gate the whole app.
///
/// Nothing here throws: a failed check fails open (reports "not enabled"),
/// so a native glitch can never lock a user out of the app.
abstract interface class IDeviceSecurityService {
  /// Whether Developer options are on and should block the app.
  ///
  /// Only enforced on Android release builds: debug/profile builds need
  /// developer mode for adb, and iOS has no public API to detect it.
  Future<bool> isDeveloperModeEnabled();

  /// Opens the system Developer options screen (falls back to Settings).
  Future<void> openDeveloperSettings();
}
