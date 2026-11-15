import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/utils/app_logger.dart';

import 'i_proximity_service.dart';

/// Android: holds a PROXIMITY_SCREEN_OFF_WAKE_LOCK (ProximityHandler.kt).
/// iOS: toggles UIDevice.isProximityMonitoringEnabled (AppDelegate.swift).
@LazySingleton(as: IProximityService)
class ProximityService implements IProximityService {
  static const _channel = MethodChannel('com.minttalk.app/proximity');

  /// Last value sent to the platform. The call cubit syncs on every state
  /// change (timer ticks included), so only real transitions cross the
  /// channel.
  bool? _applied;

  @override
  Future<void> setEnabled(bool enabled) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (_applied == enabled) return;
    _applied = enabled;
    try {
      await _channel.invokeMethod<Object?>('setEnabled', enabled);
      appLogger.d('[Proximity] enabled: $enabled');
    } catch (e) {
      // Forget the value so the next sync retries.
      _applied = null;
      appLogger.w('[Proximity] setEnabled($enabled) failed: $e');
    }
  }
}
