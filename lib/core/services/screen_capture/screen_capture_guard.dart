import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:screen_protector/screen_protector.dart';

import 'i_screen_capture_guard.dart';

/// Android: `FLAG_SECURE` on the activity window (via screen_protector) —
/// blocks screenshots, screen recording, casting and the recents thumbnail,
/// while the picture-in-picture window still renders for the user.
///
/// iOS: screen_protector's secure-layer screenshot block, plus its native
/// `preventScreenRecordOn/Off`, which the plugin's Dart API doesn't expose
/// and so is invoked on its channel directly.
@LazySingleton(as: IScreenCaptureGuard)
class ScreenCaptureGuard implements IScreenCaptureGuard {
  static const _pluginChannel = MethodChannel('screen_protector');

  /// Kill switch. On by default. To allow screen recording temporarily
  /// (e.g. for a store review), build with
  /// `--dart-define=BLOCK_SCREEN_CAPTURE=false` (or add
  /// `"BLOCK_SCREEN_CAPTURE": false` to the env/*.json define file).
  static const _enabled = bool.fromEnvironment(
    'BLOCK_SCREEN_CAPTURE',
    defaultValue: true,
  );

  final Set<String> _holders = {};

  /// What was last applied (or is being applied) on the platform.
  bool _applied = false;

  /// Serialises platform calls so a quick on/off/on can't land out of order.
  Future<void> _pending = Future.value();

  @override
  Future<void> acquire(String holder) {
    _holders.add(holder);
    return _sync();
  }

  @override
  Future<void> release(String holder) {
    _holders.remove(holder);
    return _sync();
  }

  Future<void> _sync() {
    _pending = _pending.then((_) async {
      final shouldProtect = _enabled && _holders.isNotEmpty;
      if (shouldProtect == _applied) return;
      final platform = defaultTargetPlatform;
      final isIOS = platform == TargetPlatform.iOS;
      if (platform != TargetPlatform.android && !isIOS) return;
      try {
        if (shouldProtect) {
          await ScreenProtector.preventScreenshotOn();
          if (isIOS) {
            await _pluginChannel.invokeMethod<Object?>('preventScreenRecordOn');
          }
        } else {
          await ScreenProtector.preventScreenshotOff();
          if (isIOS) {
            await _pluginChannel.invokeMethod<Object?>(
              'preventScreenRecordOff',
            );
          }
        }
        _applied = shouldProtect;
        appLogger.d('[ScreenCapture] protected: $shouldProtect $_holders');
      } catch (e) {
        appLogger.w('[ScreenCapture] apply($shouldProtect) failed: $e');
      }
    });
    return _pending;
  }
}
