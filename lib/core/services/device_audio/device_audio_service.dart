// audio_session marks its device API experimental; it's the only
// cross-platform source for connected audio devices, so we accept that.
// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/utils/app_logger.dart';

import 'device_audio_models.dart';
import 'i_device_audio_service.dart';

@LazySingleton(as: IDeviceAudioService)
class DeviceAudioService implements IDeviceAudioService {
  static const _soundModeEvents = EventChannel('com.minttalk.app/sound_mode');
  static const _control = MethodChannel('com.minttalk.app/sound_mode_control');
  static const _volumeKeyEvents = EventChannel('com.minttalk.app/volume_keys');

  static const _bluetoothTypes = {
    AudioDeviceType.bluetoothSco,
    AudioDeviceType.bluetoothA2dp,
    AudioDeviceType.bluetoothLe,
  };
  static const _wiredTypes = {
    AudioDeviceType.wiredHeadset,
    AudioDeviceType.wiredHeadphones,
  };

  @override
  Stream<DeviceSoundMode> get soundModeStream {
    if (!Platform.isAndroid) return Stream.value(DeviceSoundMode.unknown);
    return _soundModeEvents
        .receiveBroadcastStream()
        .map(_decodeSoundMode)
        .handleError((Object e) {
          appLogger.w('[DeviceAudio] Sound mode stream failed: $e');
        });
  }

  @override
  Future<DeviceSoundMode> currentSoundMode() async {
    if (!Platform.isAndroid) return DeviceSoundMode.unknown;
    try {
      final raw = await _control.invokeMethod<Object?>('getSoundMode');
      return _decodeSoundMode(raw);
    } catch (e) {
      appLogger.w('[DeviceAudio] getSoundMode failed: $e');
      return DeviceSoundMode.unknown;
    }
  }

  @override
  Stream<AudioOutputDevices> get outputDevicesStream async* {
    try {
      final session = await AudioSession.instance;
      yield* session.devicesStream.map(_summarise).distinct();
    } catch (e) {
      appLogger.w('[DeviceAudio] Device stream failed: $e');
      yield AudioOutputDevices.none;
    }
  }

  @override
  Future<void> startVibration() => _invokeAndroid('startVibration');

  @override
  Future<void> stopVibration() => _invokeAndroid('stopVibration');

  @override
  Stream<void> get volumeKeyPresses {
    if (!Platform.isAndroid) return const Stream.empty();
    return _volumeKeyEvents.receiveBroadcastStream().map((_) {}).handleError((
      Object e,
    ) {
      appLogger.w('[DeviceAudio] Volume key stream failed: $e');
    });
  }

  Future<void> _invokeAndroid(String method) async {
    if (!Platform.isAndroid) return;
    try {
      await _control.invokeMethod<void>(method);
    } catch (e) {
      appLogger.w('[DeviceAudio] $method failed: $e');
    }
  }

  static DeviceSoundMode _decodeSoundMode(Object? raw) {
    if (raw is! Map) return DeviceSoundMode.unknown;
    final ringer = switch (raw['ringerMode']) {
      'normal' => DeviceRingerMode.normal,
      'vibrate' => DeviceRingerMode.vibrate,
      'silent' => DeviceRingerMode.silent,
      _ => DeviceRingerMode.unknown,
    };
    return DeviceSoundMode(ringerMode: ringer, isDndOn: raw['dnd'] == true);
  }

  // Inputs count too: on iOS a Bluetooth headset that isn't the current
  // output only shows up among the available inputs.
  static AudioOutputDevices _summarise(Set<AudioDevice> devices) {
    final bluetooth = devices
        .where((d) => _bluetoothTypes.contains(d.type))
        .map((d) => d.name.trim())
        .firstOrNull;
    return AudioOutputDevices(
      bluetoothName: bluetooth == null
          ? null
          : (bluetooth.isEmpty ? 'Bluetooth' : bluetooth),
      hasWiredHeadset: devices.any((d) => _wiredTypes.contains(d.type)),
    );
  }
}
