import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/utils/app_logger.dart';

import 'i_call_background_service.dart';

/// Android only: CallBackgroundHandler.kt / CallForegroundService.kt.
///
/// MethodChannel `com.minttalk.app/call_background`, both directions:
/// - Dart → native: `show(Map)`, `hide()`, `setPipEnabled(bool)`.
/// - native → Dart: `pipModeChanged(bool)`, `action(String)`.
@LazySingleton(as: ICallBackgroundService)
class CallBackgroundService implements ICallBackgroundService {
  static const _channel = MethodChannel('com.minttalk.app/call_background');

  final _pipModes = StreamController<bool>.broadcast();
  final _actions = StreamController<CallBackgroundAction>.broadcast();

  CallBackgroundService() {
    if (!isSupported) return;
    _channel.setMethodCallHandler(_onNativeCall);
    // Nothing is in a call yet whenever this is created (app start, or a
    // hot restart / restarted Dart side while native still holds the last
    // call's notification or PiP state) — start from a clean slate.
    unawaited(hideOngoingCall());
    unawaited(setPipEnabled(false));
  }

  @override
  bool get isSupported => Platform.isAndroid;

  @override
  Stream<bool> get pipModeChanges => _pipModes.stream;

  @override
  Stream<CallBackgroundAction> get actions => _actions.stream;

  @override
  Future<bool> showOngoingCall(OngoingCallInfo info) async {
    if (!isSupported) return false;
    try {
      final shown = await _channel.invokeMethod<bool>('show', info.toMap());
      return shown ?? false;
    } catch (e) {
      appLogger.w('[CallBackground] show failed: $e');
      return false;
    }
  }

  @override
  Future<void> hideOngoingCall() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<Object?>('hide');
    } catch (e) {
      appLogger.w('[CallBackground] hide failed: $e');
    }
  }

  @override
  Future<void> setPipEnabled(bool enabled) async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<Object?>('setPipEnabled', enabled);
    } catch (e) {
      appLogger.w('[CallBackground] setPipEnabled($enabled) failed: $e');
    }
  }

  Future<Object?> _onNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'pipModeChanged':
        _pipModes.add(call.arguments == true);
      case 'action':
        final action = switch (call.arguments) {
          'hangUp' => CallBackgroundAction.hangUp,
          'toggleMute' => CallBackgroundAction.toggleMute,
          'toggleCamera' => CallBackgroundAction.toggleCamera,
          'openCall' => CallBackgroundAction.openCall,
          _ => null,
        };
        if (action != null) _actions.add(action);
      default:
        throw MissingPluginException(call.method);
    }
    return null;
  }
}
