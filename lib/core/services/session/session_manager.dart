import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/services/incoming_call_alert/i_incoming_call_alert_service.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mint_talk/core/widgets/session_ended_dialog.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mint_talk/features/shared/block_users/data/blocked_hosts_store.dart';

/// Single owner of "this device's session is over" handling.
///
/// The backend allows one active session per account: logging in on another
/// phone revokes this one. That surfaces here three ways — a
/// `session_terminated` socket push, a 401 on a protected API whose refresh
/// then gets a 403, or the same refresh rejection on app resume. All of them
/// funnel into [forceLogout], which tears everything down exactly once.
///
/// A forced logout is local-only: the session is already dead server-side,
/// so `/auth/logout` is deliberately not called.
@lazySingleton
class SessionManager {
  final TokenManager _tokenManager;
  final IAuthLocalDataSource _authLocalDataSource;
  final IPresenceSocketService _presenceSocketService;
  final NavigationService _navigationService;
  final BlockedHostsStore _blockedHostsStore;
  final IIncomingCallAlertService _incomingCallAlertService;

  SessionManager(
    this._tokenManager,
    this._authLocalDataSource,
    this._presenceSocketService,
    this._navigationService,
    this._blockedHostsStore,
    this._incomingCallAlertService,
  );

  static const String sessionExpiredMessage =
      'Your session has expired. Please log in again.';
  static const String sessionTerminatedMessage =
      'You were logged out because your account was signed in on another device.';

  /// Minimum gap between resume-triggered session checks, so quickly
  /// switching apps doesn't fire a refresh every time.
  static const Duration _resumeCheckInterval = Duration(seconds: 30);

  final StreamController<void> _forcedLogoutController =
      StreamController<void>.broadcast();

  /// Fires at the start of a forced logout, before the socket is dropped and
  /// tokens are cleared, so in-progress work (e.g. an active call) can shut
  /// itself down.
  Stream<void> get forcedLogouts => _forcedLogoutController.stream;

  bool _inProgress = false;

  /// Set once a forced logout completes. Requests that were already in
  /// flight keep failing with 401 after it, and each would otherwise run the
  /// whole teardown (and show the dialog) again. Cleared implicitly once a
  /// new login stores a refresh token — see [forceLogout].
  bool _hasForcedLogout = false;

  AppLifecycleListener? _lifecycleListener;
  DateTime? _lastResumeCheck;

  /// Starts checking the session whenever the app returns to the foreground.
  void startMonitoring() {
    _lifecycleListener ??= AppLifecycleListener(onResume: _onResume);
  }

  Future<void> _onResume() async {
    final now = DateTime.now();
    if (_lastResumeCheck != null &&
        now.difference(_lastResumeCheck!) < _resumeCheckInterval) {
      return;
    }
    _lastResumeCheck = now;
    await validateSession();
  }

  /// Confirms the stored session is still accepted by the backend. Logs out
  /// only when the refresh is explicitly rejected — a network failure leaves
  /// the user signed in.
  Future<void> validateSession() async {
    if (_inProgress || !await _tokenManager.hasRefreshToken()) return;

    final result = await _tokenManager.refreshAccessToken();
    if (result == RefreshResult.rejected) {
      await forceLogout(message: sessionExpiredMessage);
    }
  }

  /// Ends the local session: stops active work, disconnects the socket,
  /// clears all credentials and cached profile data, and returns to login
  /// showing [message]. [silent] skips the dialog — for a stale token found
  /// on a cold start, where the user never saw a session end.
  Future<void> forceLogout({String? message, bool silent = false}) async {
    if (_inProgress) return;
    _inProgress = true;
    try {
      // Already logged out and no new login since — a straggling 401 from a
      // request sent before the logout, nothing left to tear down.
      if (_hasForcedLogout && !await _tokenManager.hasRefreshToken()) return;

      appLogger.w(
        '[SessionManager] Forced logout: ${message ?? '(no message)'}',
      );

      _forcedLogoutController.add(null);
      _presenceSocketService.disconnect();
      // A host who was online must not stay "online" in the notification
      // shade — HostDashCubit's own stop waits for the next frame, which
      // never comes while the app is minimized.
      unawaited(_incomingCallAlertService.stopHostStandby());
      unawaited(_incomingCallAlertService.hideIncomingCall());
      // Blocks belong to this account — don't hide hosts from the next one.
      _blockedHostsStore.clear();

      try {
        await _tokenManager.clearAll();
        await _authLocalDataSource.clearAuthData();
      } catch (e) {
        appLogger.e('[SessionManager] Failed to clear stored session: $e');
      }

      _hasForcedLogout = true;
      _navigationService.navigateAndRemoveUntil(AppRoutes.phoneNumber);
      if (!silent && message != null && message.isNotEmpty) {
        _showMessage(message);
      }
    } finally {
      _inProgress = false;
    }
  }

  void _showMessage(String message) {
    // Wait for the login route to be pushed so the dialog sits above it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context =
          _navigationService.navigatorKey.currentState?.overlay?.context;
      if (context == null) return;
      showDialog<void>(
        context: context,
        builder: (_) => SessionEndedDialog(message: message),
      );
    });
  }
}
