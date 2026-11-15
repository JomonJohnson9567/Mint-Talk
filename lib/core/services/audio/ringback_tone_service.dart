import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/utils/app_logger.dart';

/// Loops the call tone: on the caller's device while the host's phone rings
/// and the call connects, and on the host's device while the incoming-call
/// dialog is ringing. Both methods are idempotent and never throw — a sound
/// failure must never break a call.
abstract interface class IRingbackToneService {
  Future<void> start();

  Future<void> stop();
}

@LazySingleton(as: IRingbackToneService)
class RingbackToneService implements IRingbackToneService {
  /// Agora owns the audio session once it joins (during `connecting`, while
  /// this tone is still looping). just_audio must therefore never activate
  /// or deactivate the shared session itself — deactivating it on stop would
  /// cut Agora's live call audio on iOS.
  AudioPlayer? _player;
  bool _isPlaying = false;

  @override
  Future<void> start() async {
    if (_isPlaying) return;
    _isPlaying = true;
    try {
      final player = _player ??= AudioPlayer(
        handleInterruptions: false,
        androidApplyAudioAttributes: false,
        handleAudioSessionActivation: false,
      );
      // Play through the iOS silent switch, like a regular call ringback.
      // Agora replaces this category with its own when it starts.
      if (Platform.isIOS) {
        await AVAudioSession().setCategory(AVAudioSessionCategory.playback);
      }
      await player.setAsset(AppAssets.ringbackTone);
      await player.setLoopMode(LoopMode.one);
      // stop() may have been called while the asset was loading.
      if (!_isPlaying) return;
      // play() only completes when playback pauses/stops — don't await it.
      player.play().catchError((Object e) {
        appLogger.w('[Ringback] Playback failed: $e');
      });
    } catch (e) {
      _isPlaying = false;
      appLogger.w('[Ringback] Could not start waiting tone: $e');
    }
  }

  @override
  Future<void> stop() async {
    if (!_isPlaying) return;
    _isPlaying = false;
    try {
      await _player?.stop();
    } catch (e) {
      appLogger.w('[Ringback] Could not stop waiting tone: $e');
    }
  }
}
