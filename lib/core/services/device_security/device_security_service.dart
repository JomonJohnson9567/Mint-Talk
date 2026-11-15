import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/utils/app_logger.dart';

import 'i_device_security_service.dart';

/// Android: DeviceSecurityHandler.kt reads
/// `Settings.Global.DEVELOPMENT_SETTINGS_ENABLED`.
@LazySingleton(as: IDeviceSecurityService)
class DeviceSecurityService implements IDeviceSecurityService {
  static const _channel = MethodChannel('com.minttalk.app/device_security');

  /// Overridable in tests; production enforces in release builds only.
  @visibleForTesting
  static bool enforce = kReleaseMode;

  bool get _isEnforced =>
      enforce && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<bool> isDeveloperModeEnabled() async {
    if (!_isEnforced) return false;
    try {
      final enabled =
          await _channel.invokeMethod<bool>('isDeveloperModeEnabled') ?? false;
      appLogger.d('[DeviceSecurity] developer mode enabled: $enabled');
      return enabled;
    } catch (e) {
      appLogger.w('[DeviceSecurity] developer mode check failed: $e');
      return false;
    }
  }

  @override
  Future<void> openDeveloperSettings() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<Object?>('openDeveloperSettings');
    } catch (e) {
      appLogger.w('[DeviceSecurity] openDeveloperSettings failed: $e');
    }
  }
}
