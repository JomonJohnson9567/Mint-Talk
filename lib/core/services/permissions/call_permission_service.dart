import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

enum CallPermissionFailure {
  microphoneDenied,
  microphonePermanentlyDenied,
  cameraDenied,
  cameraPermanentlyDenied,
}

class CallPermissionResult {
  const CallPermissionResult({
    required this.isGranted,
    this.failure,
  });

  final bool isGranted;
  final CallPermissionFailure? failure;
}

abstract interface class ICallPermissionService {
  Future<CallPermissionResult> requestPermissions({
    required bool isVideoCall,
  });

  /// Android 13+: asks for notifications if not decided yet (at most once
  /// per app run). True when granted — or not needed on this platform.
  /// Never throws.
  Future<bool> ensureNotificationPermission();
}

@LazySingleton(as: ICallPermissionService)
class CallPermissionService implements ICallPermissionService {
  /// The notification prompt is optional and sits in call setup — ask at
  /// most once per app run so a user who declined isn't asked every call.
  bool _askedForNotifications = false;

  @override
  Future<bool> ensureNotificationPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      if (await Permission.notification.isGranted) return true;
      if (_askedForNotifications) return false;
      _askedForNotifications = true;
      return (await Permission.notification.request()).isGranted;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<CallPermissionResult> requestPermissions({
    required bool isVideoCall,
  }) async {
    // 1. Request microphone permission
    final micStatus = await Permission.microphone.request();
    if (micStatus.isPermanentlyDenied) {
      return const CallPermissionResult(
        isGranted: false,
        failure: CallPermissionFailure.microphonePermanentlyDenied,
      );
    }
    if (!micStatus.isGranted) {
      return const CallPermissionResult(
        isGranted: false,
        failure: CallPermissionFailure.microphoneDenied,
      );
    }

    // 2. Request camera permission only if it is a video call
    if (isVideoCall) {
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus.isPermanentlyDenied) {
        return const CallPermissionResult(
          isGranted: false,
          failure: CallPermissionFailure.cameraPermanentlyDenied,
        );
      }
      if (!cameraStatus.isGranted) {
        return const CallPermissionResult(
          isGranted: false,
          failure: CallPermissionFailure.cameraDenied,
        );
      }
    }

    // 3. Bluetooth (Android 12+) — needed to route call audio to a
    // Bluetooth headset. Optional: a denial only hides that route, it never
    // blocks the call. Older Android grants it at install, iOS doesn't use it.
    if (Platform.isAndroid) {
      try {
        await Permission.bluetoothConnect.request();
      } catch (_) {
        // Never let an optional permission break call setup.
      }

      // 4. Notifications (Android 13+) — shows the ongoing-call notification
      // while the app is in the background. Optional too: without it the
      // call still keeps running, the notification is just hidden.
      try {
        if (!_askedForNotifications) {
          _askedForNotifications = true;
          await Permission.notification.request();
        }
      } catch (_) {
        // Never let an optional permission break call setup.
      }
    }

    return const CallPermissionResult(isGranted: true);
  }
}
