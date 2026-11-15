import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/services/audio/ringback_tone_service.dart';
import 'package:mint_talk/core/services/device_audio/device_audio_models.dart';
import 'package:mint_talk/core/services/device_audio/i_device_audio_service.dart';
import 'package:mint_talk/core/utils/app_logger.dart';

/// Rings the host's device for an incoming call, following the device's
/// sound mode like a regular phone call:
/// - normal → tone + vibration
/// - vibrate → vibration only
/// - silent or Do Not Disturb → nothing
/// - unknown (iOS) → tone only, the previous behaviour
///
/// Mode changes while ringing apply immediately (e.g. flipping to silent
/// stops the tone). A volume-key press (Android) silences tone and
/// vibration for the rest of this call, like a regular phone call; the
/// press itself does not change the volume. Both methods are idempotent
/// and never throw.
abstract interface class IIncomingRingerService {
  Future<void> start();

  Future<void> stop();
}

@LazySingleton(as: IIncomingRingerService)
class IncomingRingerService implements IIncomingRingerService {
  final IRingbackToneService _tone;
  final IDeviceAudioService _deviceAudio;

  IncomingRingerService(this._tone, this._deviceAudio);

  bool _isRinging = false;
  bool _isTonePlaying = false;
  bool _isVibrating = false;
  bool _isSilencedByUser = false;
  StreamSubscription<DeviceSoundMode>? _modeSub;

  /// Listening arms the native volume-key interception; cancelling it
  /// hands the keys back to the system.
  StreamSubscription<void>? _keySub;

  @override
  Future<void> start() async {
    if (_isRinging) return;
    _isRinging = true;
    _isSilencedByUser = false;
    try {
      await _apply(await _deviceAudio.currentSoundMode());
      if (!_isRinging) return; // stop() raced the mode lookup.
      _modeSub = _deviceAudio.soundModeStream.listen(
        (mode) => unawaited(_apply(mode)),
        onError: (Object e) => appLogger.w('[IncomingRinger] Mode stream: $e'),
      );
      _keySub = _deviceAudio.volumeKeyPresses.listen(
        (_) => unawaited(_silenceByUser()),
        onError: (Object e) => appLogger.w('[IncomingRinger] Key stream: $e'),
      );
    } catch (e) {
      appLogger.w('[IncomingRinger] Could not start ringing: $e');
    }
  }

  @override
  Future<void> stop() async {
    if (!_isRinging) return;
    _isRinging = false;
    await _modeSub?.cancel();
    _modeSub = null;
    await _keySub?.cancel();
    _keySub = null;
    await _setTone(false);
    await _setVibration(false);
  }

  /// Only the first press is swallowed; later presses adjust the volume.
  Future<void> _silenceByUser() async {
    if (!_isRinging || _isSilencedByUser) return;
    _isSilencedByUser = true;
    appLogger.d('[IncomingRinger] Silenced by volume key');
    final keySub = _keySub;
    _keySub = null;
    await keySub?.cancel();
    await _setTone(false);
    await _setVibration(false);
  }

  Future<void> _apply(DeviceSoundMode mode) async {
    if (!_isRinging || _isSilencedByUser) return;
    final (tone, vibrate) = ringBehaviourFor(mode);
    appLogger.d('[IncomingRinger] Mode $mode → tone=$tone vibrate=$vibrate');
    await _setTone(tone);
    await _setVibration(vibrate);
  }

  Future<void> _setTone(bool on) async {
    if (on == _isTonePlaying) return;
    _isTonePlaying = on;
    await (on ? _tone.start() : _tone.stop());
  }

  Future<void> _setVibration(bool on) async {
    if (on == _isVibrating) return;
    _isVibrating = on;
    await (on ? _deviceAudio.startVibration() : _deviceAudio.stopVibration());
  }
}

/// `(playTone, vibrate)` for [mode].
(bool, bool) ringBehaviourFor(DeviceSoundMode mode) {
  if (mode.isSilenced) return (false, false);
  return switch (mode.ringerMode) {
    DeviceRingerMode.normal => (true, true),
    DeviceRingerMode.vibrate => (false, true),
    DeviceRingerMode.silent => (false, false),
    DeviceRingerMode.unknown => (true, false),
  };
}
