import 'package:equatable/equatable.dart';

/// The device's ringer switch. [unknown] where the OS doesn't expose it
/// (iOS has no public API for the silent switch).
enum DeviceRingerMode { normal, vibrate, silent, unknown }

/// Ringer mode plus Do Not Disturb. Only readable on Android; iOS always
/// reports [DeviceSoundMode.unknown].
class DeviceSoundMode extends Equatable {
  final DeviceRingerMode ringerMode;
  final bool isDndOn;

  const DeviceSoundMode({required this.ringerMode, required this.isDndOn});

  static const unknown = DeviceSoundMode(
    ringerMode: DeviceRingerMode.unknown,
    isDndOn: false,
  );

  /// True when an incoming ring should make no sound at all.
  bool get isSilenced => isDndOn || ringerMode == DeviceRingerMode.silent;

  @override
  List<Object?> get props => [ringerMode, isDndOn];
}

/// The audio accessories currently connected.
class AudioOutputDevices extends Equatable {
  /// Name of the connected Bluetooth audio device, or null if none.
  final String? bluetoothName;
  final bool hasWiredHeadset;

  const AudioOutputDevices({this.bluetoothName, this.hasWiredHeadset = false});

  static const none = AudioOutputDevices();

  bool get hasBluetooth => bluetoothName != null;

  @override
  List<Object?> get props => [bluetoothName, hasWiredHeadset];
}
