import 'dart:async';

import 'package:mint_talk/core/services/device_audio/device_audio_models.dart';
import 'package:mint_talk/core/services/device_audio/i_device_audio_service.dart';

/// Watches the device's sound mode and connected audio devices for the
/// lifetime of one call, kept out of [CallScreenCubit] so the cubit only
/// maps the updates into state.
class CallDeviceAudioWatcher {
  final IDeviceAudioService _deviceAudio;

  CallDeviceAudioWatcher(this._deviceAudio);

  StreamSubscription<DeviceSoundMode>? _soundModeSub;
  StreamSubscription<AudioOutputDevices>? _devicesSub;

  /// (Re)starts both subscriptions. Each stream emits its current value
  /// on listen, so the callbacks fire right away with the initial state.
  void start({
    required void Function(DeviceSoundMode) onSoundMode,
    required void Function(AudioOutputDevices) onDevices,
  }) {
    stop();
    _soundModeSub = _deviceAudio.soundModeStream.listen(
      onSoundMode,
      onError: (Object _) {},
    );
    _devicesSub = _deviceAudio.outputDevicesStream.listen(
      onDevices,
      onError: (Object _) {},
    );
  }

  void stop() {
    _soundModeSub?.cancel();
    _soundModeSub = null;
    _devicesSub?.cancel();
    _devicesSub = null;
  }
}
