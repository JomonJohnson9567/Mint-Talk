import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/services/agora/call_audio_route.dart';
import 'package:mint_talk/core/services/audio/incoming_ringer_service.dart';
import 'package:mint_talk/core/services/audio/ringback_tone_service.dart';
import 'package:mint_talk/core/services/device_audio/device_audio_models.dart';
import 'package:mint_talk/core/services/device_audio/i_device_audio_service.dart';

class _FakeTone implements IRingbackToneService {
  bool isPlaying = false;

  @override
  Future<void> start() async => isPlaying = true;

  @override
  Future<void> stop() async => isPlaying = false;
}

class _FakeDeviceAudio implements IDeviceAudioService {
  _FakeDeviceAudio(this.initial);

  DeviceSoundMode initial;
  final modes = StreamController<DeviceSoundMode>.broadcast();
  bool isVibrating = false;

  @override
  Future<DeviceSoundMode> currentSoundMode() async => initial;

  @override
  Stream<DeviceSoundMode> get soundModeStream => modes.stream;

  @override
  Stream<AudioOutputDevices> get outputDevicesStream => const Stream.empty();

  @override
  Future<void> startVibration() async => isVibrating = true;

  @override
  Future<void> stopVibration() async => isVibrating = false;

  final keys = StreamController<void>.broadcast();

  @override
  Stream<void> get volumeKeyPresses => keys.stream;
}

const _normal = DeviceSoundMode(ringerMode: DeviceRingerMode.normal, isDndOn: false);
const _vibrate = DeviceSoundMode(ringerMode: DeviceRingerMode.vibrate, isDndOn: false);
const _silent = DeviceSoundMode(ringerMode: DeviceRingerMode.silent, isDndOn: false);
const _dnd = DeviceSoundMode(ringerMode: DeviceRingerMode.normal, isDndOn: true);

void main() {
  late _FakeTone tone;
  late _FakeDeviceAudio device;
  late IncomingRingerService ringer;

  void build(DeviceSoundMode mode) {
    tone = _FakeTone();
    device = _FakeDeviceAudio(mode);
    ringer = IncomingRingerService(tone, device);
  }

  final cases = <String, (DeviceSoundMode, bool, bool)>{
    'normal → tone + vibration': (_normal, true, true),
    'vibrate → vibration only': (_vibrate, false, true),
    'silent → nothing': (_silent, false, false),
    'DND → nothing': (_dnd, false, false),
    'unknown (iOS) → tone only': (DeviceSoundMode.unknown, true, false),
  };
  cases.forEach((name, c) {
    final (mode, expectTone, expectVibration) = c;
    test(name, () async {
      build(mode);
      await ringer.start();
      expect(tone.isPlaying, expectTone);
      expect(device.isVibrating, expectVibration);
    });
  });

  test('switching to silent mid-ring stops tone and vibration', () async {
    build(_normal);
    await ringer.start();

    device.modes.add(_silent);
    await pumpEventQueue();

    expect(tone.isPlaying, isFalse);
    expect(device.isVibrating, isFalse);
  });

  test('switching from vibrate to normal mid-ring starts the tone', () async {
    build(_vibrate);
    await ringer.start();

    device.modes.add(_normal);
    await pumpEventQueue();

    expect(tone.isPlaying, isTrue);
    expect(device.isVibrating, isTrue);
  });

  test('stop silences everything and ignores later mode changes', () async {
    build(_normal);
    await ringer.start();
    await ringer.stop();

    device.modes.add(_normal);
    await pumpEventQueue();

    expect(tone.isPlaying, isFalse);
    expect(device.isVibrating, isFalse);
    expect(device.modes.hasListener, isFalse);
  });

  group('volume key', () {
    test('one press silences tone and vibration', () async {
      build(_normal);
      await ringer.start();

      device.keys.add(null);
      await pumpEventQueue();

      expect(tone.isPlaying, isFalse);
      expect(device.isVibrating, isFalse);
    });

    test('hands the keys back to the system after the first press', () async {
      build(_normal);
      await ringer.start();
      expect(device.keys.hasListener, isTrue);

      device.keys.add(null);
      await pumpEventQueue();

      expect(device.keys.hasListener, isFalse);
    });

    test('a later mode change does not restart the ring', () async {
      build(_vibrate);
      await ringer.start();

      device.keys.add(null);
      await pumpEventQueue();
      device.modes.add(_normal);
      await pumpEventQueue();

      expect(tone.isPlaying, isFalse);
      expect(device.isVibrating, isFalse);
    });

    test('stop releases the keys', () async {
      build(_normal);
      await ringer.start();
      await ringer.stop();

      expect(device.keys.hasListener, isFalse);
    });

    test('the next call rings again after a silenced one', () async {
      build(_normal);
      await ringer.start();
      device.keys.add(null);
      await pumpEventQueue();
      await ringer.stop();

      await ringer.start();

      expect(tone.isPlaying, isTrue);
      expect(device.isVibrating, isTrue);
      expect(device.keys.hasListener, isTrue);
    });
  });

  test('Agora routing ints map to call audio routes', () {
    expect(callAudioRouteFromAgora(1), CallAudioRoute.earpiece);
    expect(callAudioRouteFromAgora(3), CallAudioRoute.speaker);
    expect(callAudioRouteFromAgora(4), CallAudioRoute.speaker);
    expect(callAudioRouteFromAgora(0), CallAudioRoute.wiredHeadset);
    expect(callAudioRouteFromAgora(5), CallAudioRoute.bluetooth);
    expect(callAudioRouteFromAgora(10), CallAudioRoute.bluetooth);
    expect(callAudioRouteFromAgora(-1), isNull);
    for (final route in CallAudioRoute.values) {
      expect(callAudioRouteFromAgora(agoraCommunicationRouteFor(route)), route);
    }
  });
}
