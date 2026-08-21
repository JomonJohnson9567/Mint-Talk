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
}

@LazySingleton(as: ICallPermissionService)
class CallPermissionService implements ICallPermissionService {
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

    return const CallPermissionResult(isGranted: true);
  }
}
