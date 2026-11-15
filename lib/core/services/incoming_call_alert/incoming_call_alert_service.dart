import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/utils/app_logger.dart';

import 'i_incoming_call_alert_service.dart';

/// Android only: IncomingCallHandler.kt / IncomingCallNotifier.kt /
/// CallForegroundService.kt (standby mode).
///
/// MethodChannel `com.minttalk.app/incoming_call`, both directions:
/// - Dart → native: `showStandby(Map)`, `hideStandby()`,
///   `showIncomingCall(Map)`, `hideIncomingCall()`,
///   `clearLockScreenOverride()`.
/// - native → Dart: `incomingAction({action, callId})`.
@LazySingleton(as: IIncomingCallAlertService)
class IncomingCallAlertService implements IIncomingCallAlertService {
  static const _channel = MethodChannel('com.minttalk.app/incoming_call');

  final _actions = StreamController<IncomingCallAction>.broadcast();

  IncomingCallAlertService() {
    if (!isSupported) return;
    _channel.setMethodCallHandler(_onNativeCall);
    // Nobody is online or ringing whenever this is created (app start, or a
    // hot restart while native still shows the last session's
    // notifications) — start from a clean slate.
    unawaited(hideIncomingCall());
    unawaited(stopHostStandby());
  }

  @override
  bool get isSupported => Platform.isAndroid;

  @override
  Stream<IncomingCallAction> get actions => _actions.stream;

  @override
  Future<bool> startHostStandby({
    required bool audio,
    required bool video,
  }) async {
    if (!isSupported) return false;
    try {
      final shown = await _channel.invokeMethod<bool>('showStandby', {
        'audio': audio,
        'video': video,
      });
      return shown ?? false;
    } catch (e) {
      appLogger.w('[IncomingCallAlert] showStandby failed: $e');
      return false;
    }
  }

  @override
  Future<void> stopHostStandby() => _invoke('hideStandby');

  @override
  Future<bool> showIncomingCall(IncomingCallAlert alert) async {
    if (!isSupported) return false;
    try {
      final shown = await _channel.invokeMethod<bool>(
        'showIncomingCall',
        alert.toMap(),
      );
      return shown ?? false;
    } catch (e) {
      appLogger.w('[IncomingCallAlert] showIncomingCall failed: $e');
      return false;
    }
  }

  @override
  Future<void> hideIncomingCall() => _invoke('hideIncomingCall');

  @override
  Future<void> clearLockScreenOverride() => _invoke('clearLockScreenOverride');

  Future<void> _invoke(String method) async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<Object?>(method);
    } catch (e) {
      appLogger.w('[IncomingCallAlert] $method failed: $e');
    }
  }

  Future<Object?> _onNativeCall(MethodCall call) async {
    if (call.method != 'incomingAction') {
      throw MissingPluginException(call.method);
    }
    final args = call.arguments;
    if (args is! Map) return null;
    final callId = args['callId']?.toString() ?? '';
    final type = switch (args['action']) {
      'answer' => IncomingCallActionType.answer,
      'decline' => IncomingCallActionType.decline,
      'open' => IncomingCallActionType.open,
      _ => null,
    };
    if (type != null && callId.isNotEmpty) {
      _actions.add(IncomingCallAction(type, callId));
    }
    return null;
  }
}
