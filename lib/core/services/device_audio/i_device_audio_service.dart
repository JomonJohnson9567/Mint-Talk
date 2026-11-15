import 'device_audio_models.dart';

/// Reads the device's audio situation: ringer mode and Do Not Disturb
/// (Android only), connected Bluetooth/wired audio devices (both
/// platforms), and drives the incoming-call vibration (Android only).
///
/// Nothing here throws: a failure degrades to "unknown" / "no devices" so
/// it can never break a call.
abstract interface class IDeviceAudioService {
  /// Emits the current mode on listen, then on every change. A single
  /// [DeviceSoundMode.unknown] on iOS.
  Stream<DeviceSoundMode> get soundModeStream;

  Future<DeviceSoundMode> currentSoundMode();

  /// Emits the connected devices on listen, then on every change.
  Stream<AudioOutputDevices> get outputDevicesStream;

  /// Starts a repeating ring vibration. No-op on iOS.
  Future<void> startVibration();

  Future<void> stopVibration();

  /// Emits once per hardware volume-key press while listened to. While
  /// there is a listener, Android swallows the press so the volume does
  /// not change. Empty on iOS (its volume buttons cannot be intercepted).
  Stream<void> get volumeKeyPresses;
}
