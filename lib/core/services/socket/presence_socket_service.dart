import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:mint_talk/config/env/env_config.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mint_talk/features/user_side/home/data/models/host_presence_dto.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_presence_entity.dart';

import 'i_presence_socket_service.dart';

/// Socket.io event names
class _SocketEvents {
  static const String hostStatusUpdate = 'host_status_update';
  static const String updateAvailability = 'update_availability';
  static const String sessionTerminated = 'session_terminated';
  static const String connect = 'connect';
  static const String connectError = 'connect_error';
  static const String disconnect = 'disconnect';
  static const String getPresenceSnapshot = 'get_presence_snapshot';
  static const String subscribeFavorites = 'subscribe_favorites';

  // Call signaling events
  static const String incomingCall = 'incoming_call';
  static const String callStatusUpdated = 'call_status_updated';
  static const String callStatusUpdate = 'call_status_update';
  static const String callAccepted = 'call_accepted';
  static const String subscribeCall = 'subscribe_call';
  static const String unsubscribeCall = 'unsubscribe_call';

  // Notifications
  static const String newNotification = 'new_notification';

  // Chat
  static const String newChatMessage = 'new_message';

}

/// Concrete implementation of [IPresenceSocketService] using `socket_io_client`.
@LazySingleton(as: IPresenceSocketService)
class PresenceSocketService implements IPresenceSocketService {
  final EnvConfig _envConfig;
  final TokenManager _tokenManager;
  final Logger _logger = Logger();

  io.Socket? _socket;
  StreamController<HostPresenceEntity>? _controller;
  StreamController<Map<String, dynamic>>? _incomingCallController;
  StreamController<Map<String, dynamic>>? _callStatusController;
  StreamController<Map<String, dynamic>>? _newNotificationController;
  StreamController<Map<String, dynamic>>? _newChatMessageController;

  /// Buffered availability update — flushed automatically on the next connect.
  bool? _pendingAudioAvailable;
  bool? _pendingVideoAvailable;

  /// Prevents concurrent reconnect attempts.
  bool _isReconnecting = false;

  /// True from the moment a connection attempt starts until it definitively
  /// resolves (successful `connect`, exhausted retries, or an explicit
  /// [disconnect]). Guards the *public* [connect] entry point against a
  /// caller (e.g. a cubit re-asserting "make sure the socket is connected")
  /// tearing down and restarting an already in-flight attempt — which would
  /// interrupt a retry/backoff cycle that might otherwise have succeeded on
  /// its own and burn through the auth-refresh budget faster than intended.
  /// Internal retries call [_createAndConnect] directly and are unaffected.
  bool _connectInFlight = false;

  /// True once we've already logged/propagated a connect error for the
  /// current disconnect streak — reset back to false on the next successful
  /// `connect`. Prevents the socket's built-in reconnection loop (which
  /// retries every few seconds while the screen is off / network is briefly
  /// unreachable) from spamming logs and cubit error streams every attempt.
  bool _hasReportedConnectError = false;
  int _consecutiveConnectErrors = 0;

  /// Caps the auth-refresh-and-reconnect path below. Without this, a
  /// refreshed token that the socket server keeps rejecting (backend bug,
  /// clock skew, a refresh token that doesn't actually rotate — any of
  /// these) sends this handler into an unbounded refresh→reconnect→fail
  /// loop that never lets the user reach a real login screen.
  static const int _maxAuthRefreshAttempts = 3;
  int _authRefreshAttempts = 0;

  PresenceSocketService(this._envConfig, this._tokenManager);

  @override
  Stream<HostPresenceEntity> get presenceUpdates {
    _controller ??= StreamController<HostPresenceEntity>.broadcast();
    return _controller!.stream;
  }

  @override
  Stream<Map<String, dynamic>> get incomingCalls {
    _incomingCallController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _incomingCallController!.stream;
  }

  @override
  Stream<Map<String, dynamic>> get callStatusUpdates {
    _callStatusController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _callStatusController!.stream;
  }

  @override
  Stream<Map<String, dynamic>> get newNotifications {
    _newNotificationController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _newNotificationController!.stream;
  }

  @override
  Stream<Map<String, dynamic>> get newChatMessages {
    _newChatMessageController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _newChatMessageController!.stream;
  }

  @override
  void connect(String accessToken) {
    // Ensure the stream controllers are alive before registering listeners.
    if (_controller == null || _controller!.isClosed) {
      _controller = StreamController<HostPresenceEntity>.broadcast();
    }
    if (_incomingCallController == null || _incomingCallController!.isClosed) {
      _incomingCallController = StreamController<Map<String, dynamic>>.broadcast();
    }
    if (_callStatusController == null || _callStatusController!.isClosed) {
      _callStatusController = StreamController<Map<String, dynamic>>.broadcast();
    }
    if (_newNotificationController == null || _newNotificationController!.isClosed) {
      _newNotificationController = StreamController<Map<String, dynamic>>.broadcast();
    }
    if (_newChatMessageController == null || _newChatMessageController!.isClosed) {
      _newChatMessageController = StreamController<Map<String, dynamic>>.broadcast();
    }

    if (_socket != null) {
      if (_socket!.connected) {
        _logger.d('[PresenceSocket] Already connected — requesting snapshot.');
        _requestSnapshot();
        return;
      }
      if (_connectInFlight) {
        _logger.d(
          '[PresenceSocket] Connection attempt already in flight — ignoring duplicate connect().',
        );
        return;
      }
      _logger.d('[PresenceSocket] Re-creating socket connection...');
      _socket!.dispose();
      _socket = null;
    }

    _logger.d('[PresenceSocket] Connecting to ${_envConfig.socketUrl}');
    _connectInFlight = true;
    _createAndConnect(accessToken);
  }

  void _createAndConnect(String accessToken) {
    _socket = io.io(
      _envConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': accessToken, 'auth': accessToken})
          .setExtraHeaders({'Authorization': 'Bearer $accessToken'})
          // Graceful exponential backoff instead of hammering the network
          // every ~1s while the phone is asleep / briefly offline (which is
          // what produced the repeated "Failed host lookup" log spam).
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(20000)
          .setRandomizationFactor(0.5)
          .build(),
    );
    _registerListeners();
    _socket!.connect();
  }

  /// Requests the server to send the current presence snapshot.
  ///
  /// The server is expected to reply with one or more [host_status_update]
  /// events, one per currently online/busy host.
  void _requestSnapshot() {
    if (_socket != null && _socket!.connected) {
      _logger.d('[PresenceSocket] Emitting get_presence_snapshot');
      _socket!.emit(_SocketEvents.getPresenceSnapshot);
    }
  }

  @override
  void subscribeFavorites() {
    if (_socket != null && _socket!.connected) {
      _logger.d('[PresenceSocket] Emitting subscribe_favorites');
      _socket!.emit(_SocketEvents.subscribeFavorites);
    }
  }

  @override
  void updateAvailability({
    required bool audioAvailable,
    required bool videoAvailable,
  }) {
    if (_socket != null && _socket!.connected) {
      _logger.d(
        '✅ [PresenceSocket] Emitting update_availability: '
        'audio=$audioAvailable, video=$videoAvailable',
      );
      _socket!.emit(_SocketEvents.updateAvailability, {
        'audio_available': audioAvailable,
        'video_available': videoAvailable,
      });
      // Clear any pending buffer since we just emitted.
      _pendingAudioAvailable = null;
      _pendingVideoAvailable = null;
    } else {
      // Socket is connecting but not yet ready — buffer the intent.
      // It will be emitted automatically in the connect event handler.
      _logger.w(
        '⏳ [PresenceSocket] Socket not yet connected — '
        'buffering update_availability(audio=$audioAvailable, video=$videoAvailable) '
        'until handshake completes.',
      );
      _pendingAudioAvailable = audioAvailable;
      _pendingVideoAvailable = videoAvailable;
    }
  }

  @override
  void subscribeCall(String callId) {
    if (_socket != null && _socket!.connected) {
      _logger.d('[PresenceSocket] Emitting subscribe_call for callId: $callId');
      _socket!.emit(_SocketEvents.subscribeCall, {'callId': callId});
    }
  }

  @override
  void unsubscribeCall(String callId) {
    if (_socket != null && _socket!.connected) {
      _logger.d('[PresenceSocket] Emitting unsubscribe_call for callId: $callId');
      _socket!.emit(_SocketEvents.unsubscribeCall, {'callId': callId});
    }
  }



  @override
  void disconnect() {
    _logger.d('[PresenceSocket] Disconnecting.');
    _connectInFlight = false;
    _socket?.disconnect();
  }

  @override
  void dispose() {
    _logger.d('[PresenceSocket] Disposing.');
    _connectInFlight = false;
    _socket?.dispose();
    _socket = null;
    _controller?.close();
    _controller = null;
    _incomingCallController?.close();
    _incomingCallController = null;
    _callStatusController?.close();
    _callStatusController = null;
    _newNotificationController?.close();
    _newNotificationController = null;
    _newChatMessageController?.close();
    _newChatMessageController = null;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _handleCallStatusData(dynamic data) {
    try {
      _logger.i('📲 [PresenceSocket] call status event received: $data');
      if (_callStatusController != null && !_callStatusController!.isClosed) {
        if (data is Map) {
          _callStatusController!.add(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      _logger.e('[PresenceSocket] Error processing call status: $e');
    }
  }

  void _registerListeners() {
    // ── Wildcard: log EVERY event the server sends ──────────────────────────
    // This catches any event name so we can see the exact server contract.
    _socket!.onAny((event, data) {
      _logger.d(
        '📡 [PresenceSocket] RAW EVENT ► "$event"\n'
        '   payload type : ${data.runtimeType}\n'
        '   payload value: $data',
      );
    });

    _socket!.on(_SocketEvents.connect, (_) {
      try {
        _logger.i(
          '✅ [PresenceSocket] Connected to ${_envConfig.socketUrl}\n'
          '   socket id : ${_socket?.id}',
        );

        // Reset the error-dedupe streak now that we're back online.
        _hasReportedConnectError = false;
        _consecutiveConnectErrors = 0;
        _authRefreshAttempts = 0;
        _connectInFlight = false;

        // Flush any buffered availability update that arrived before the
        // handshake completed.
        if (_pendingAudioAvailable != null && _pendingVideoAvailable != null) {
          _logger.d(
            '⚡ [PresenceSocket] Flushing buffered update_availability: '
            'audio=$_pendingAudioAvailable, video=$_pendingVideoAvailable',
          );
          _socket!.emit(_SocketEvents.updateAvailability, {
            'audio_available': _pendingAudioAvailable,
            'video_available': _pendingVideoAvailable,
          });
          _pendingAudioAvailable = null;
          _pendingVideoAvailable = null;
        }

        // Request the current online/busy host list snapshot.
        _requestSnapshot();

        // Ask the server to include favorited-host updates in this same
        // push channel — re-emitted automatically on every reconnect.
        subscribeFavorites();
      } catch (e) {
        _logger.e('[PresenceSocket] Error in connect handler: $e');
      }
    });

    _socket!.on(_SocketEvents.hostStatusUpdate, (data) {
      try {
        _logger.i(
          '🟢 [PresenceSocket] host_status_update received\n'
          '   raw type   : ${data.runtimeType}\n'
          '   raw payload: $data',
        );

        final List<Map<String, dynamic>> items = [];

        if (data is List) {
          _logger.d('   → payload is a List with ${data.length} element(s)');
          for (final item in data) {
            if (item is Map) {
              items.add(Map<String, dynamic>.from(item));
            } else {
              _logger.w('   → skipped non-Map list element: ${item.runtimeType} = $item');
            }
          }
        } else if (data is Map) {
          _logger.d('   → payload is a Map, checking for nested list keys');
          final rawList = data['hosts'] ?? data['items'] ?? data['data'];
          if (rawList is List) {
            _logger.d('   → found nested list under key, length=${rawList.length}');
            for (final item in rawList) {
              if (item is Map) {
                items.add(Map<String, dynamic>.from(item));
              }
            }
          } else {
            _logger.d('   → treating whole Map as a single presence object');
            items.add(Map<String, dynamic>.from(data));
          }
        } else {
          _logger.w('   → unexpected payload type: ${data.runtimeType}');
        }

        _logger.i('   → parsed ${items.length} presence object(s):');
        for (int i = 0; i < items.length; i++) {
          _logger.i('      [$i] ${items[i]}');
        }

        int emitted = 0;
        for (final itemMap in items) {
          final entity = HostPresenceDto.fromJson(itemMap).toEntity();
          if (entity.userId.isNotEmpty &&
              _controller != null &&
              !_controller!.isClosed) {
            _controller!.add(entity);
            emitted++;
            _logger.d(
              '   → emitted to stream: userId=${entity.userId} '
              'status=${entity.status} busy=${entity.busy} '
              'state=${entity.state}',
            );
          } else if (entity.userId.isEmpty) {
            _logger.w('   → skipped entity with empty userId: $itemMap');
          }
        }
        _logger.i('   → $emitted entity/entities pushed to stream');
      } catch (e, st) {
        _logger.e('[PresenceSocket] Failed to parse host_status_update: $e\n$st');
      }
    });

    _socket!.on(_SocketEvents.incomingCall, (data) {
      try {
        _logger.i('📞 [PresenceSocket] incoming_call event received: $data');
        if (data is Map &&
            _incomingCallController != null &&
            !_incomingCallController!.isClosed) {
          _incomingCallController!.add(Map<String, dynamic>.from(data));
        }
      } catch (e) {
        _logger.e('[PresenceSocket] Error processing incoming_call: $e');
      }
    });

    _socket!.on(_SocketEvents.newNotification, (data) {
      try {
        _logger.i('🔔 [PresenceSocket] new_notification event received: $data');
        if (data is Map &&
            _newNotificationController != null &&
            !_newNotificationController!.isClosed) {
          _newNotificationController!.add(Map<String, dynamic>.from(data));
        }
      } catch (e) {
        _logger.e('[PresenceSocket] Error processing new_notification: $e');
      }
    });

    _socket!.on(_SocketEvents.newChatMessage, (data) {
      try {
        _logger.i('💬 [PresenceSocket] new_message event received: $data');
        if (data is Map &&
            _newChatMessageController != null &&
            !_newChatMessageController!.isClosed) {
          _newChatMessageController!.add(Map<String, dynamic>.from(data));
        }
      } catch (e) {
        _logger.e('[PresenceSocket] Error processing new_message: $e');
      }
    });

    _socket!.on(_SocketEvents.callStatusUpdated, _handleCallStatusData);
    _socket!.on(_SocketEvents.callStatusUpdate, _handleCallStatusData);
    _socket!.on(_SocketEvents.callAccepted, (data) {
      final mapData =
          data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      mapData['status'] = 'accepted';
      _handleCallStatusData(mapData);
    });
    _socket!.on('call_ended', (data) {
      final mapData =
          data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      mapData['status'] = 'ended';
      _handleCallStatusData(mapData);
    });
    _socket!.on('call_rejected', (data) {
      final mapData =
          data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      mapData['status'] = 'rejected';
      _handleCallStatusData(mapData);
    });
    _socket!.on('call_missed', (data) {
      final mapData =
          data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      mapData['status'] = 'missed';
      _handleCallStatusData(mapData);
    });
    _socket!.on('call_cancelled', (data) {
      final mapData =
          data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      mapData['status'] = 'missed';
      _handleCallStatusData(mapData);
    });

    _socket!.on(_SocketEvents.sessionTerminated, (data) async {
      try {
        final message = data is Map
            ? (data['message']?.toString() ??
                'Session terminated due to login from another device.')
            : (data?.toString() ??
                'Session terminated due to login from another device.');
        _logger.w(
          '[PresenceSocket] Session terminated — clearing tokens & logging out: $message',
        );
        await getIt<TokenManager>().clearAll();
        getIt<NavigationService>().navigateAndRemoveUntil(
          AppRoutes.phoneNumber,
          arguments: {'message': message},
        );
      } catch (e) {
        _logger.e('[PresenceSocket] Error handling session_terminated: $e');
      }
    });

    _socket!.on(_SocketEvents.connectError, (err) async {
      try {
        final errMsg = err?.toString() ?? '';
        _consecutiveConnectErrors++;

        // The socket's own reconnection loop retries on a backoff timer
        // (see setReconnectionDelay/Max above) — that's expected and normal
        // while the screen is off or the network briefly drops. Only the
        // *first* failure of a streak is worth a full log line; log the
        // rest tersely so a long screen-off period doesn't flood logcat.
        if (!_hasReportedConnectError) {
          _hasReportedConnectError = true;
          _logger.e('[PresenceSocket] Connection error: $err');
        } else {
          _logger.d(
            '[PresenceSocket] Still reconnecting… '
            '(attempt #$_consecutiveConnectErrors)',
          );
        }

        // Detect authentication / token expiry errors and attempt refresh + reconnect.
        // Auth errors should NOT be propagated to the stream as fatal errors —
        // the app should silently refresh the token and reconnect instead.
        final isAuthError = errMsg.toLowerCase().contains('auth') ||
            errMsg.toLowerCase().contains('expired') ||
            errMsg.toLowerCase().contains('session') ||
            errMsg.toLowerCase().contains('token') ||
            errMsg.toLowerCase().contains('unauthorized');

        if (isAuthError && !_isReconnecting) {
          if (_authRefreshAttempts >= _maxAuthRefreshAttempts) {
            // The refreshed token has failed at the socket layer
            // _maxAuthRefreshAttempts times in a row — refreshing again
            // isn't going to fix it (backend issue, clock skew, a refresh
            // token that isn't actually rotating, etc.). Stop looping and
            // force a real logout instead of retrying forever.
            _logger.e(
              '[PresenceSocket] Auth refresh retry limit reached '
              '($_maxAuthRefreshAttempts attempts) — logging out.',
            );
            _connectInFlight = false;
            await _tokenManager.clearAll();
            getIt<NavigationService>().navigateAndRemoveUntil(
              AppRoutes.phoneNumber,
              arguments: {'message': 'Session expired. Please log in again.'},
            );
            return;
          }

          _authRefreshAttempts++;
          _isReconnecting = true;
          _logger.w(
            '[PresenceSocket] Auth error — attempting token refresh & reconnect '
            '(attempt $_authRefreshAttempts/$_maxAuthRefreshAttempts)...',
          );

          final refreshed = await _tokenManager.refreshAccessToken();
          if (refreshed) {
            final newToken = _tokenManager.getAccessToken();
            if (newToken != null && newToken.isNotEmpty) {
              // Give the backend a moment to settle before reconnecting —
              // reconnecting instantly after a refresh can hit the exact
              // same "session expired" rejection if the server's session
              // store hasn't finished propagating the refresh yet, burning
              // through the retry budget on a race rather than a real
              // failure. Backs off a little more on each attempt.
              await Future.delayed(Duration(seconds: _authRefreshAttempts));
              _logger.i('[PresenceSocket] Token refreshed — reconnecting socket...');
              _socket?.dispose();
              _socket = null;
              _isReconnecting = false;
              _createAndConnect(newToken);
              return;
            }
          }

          // Refresh failed — session is truly expired, clear tokens and navigate to login
          _logger.e('[PresenceSocket] Token refresh failed — session expired. Logging out.');
          _isReconnecting = false;
          _connectInFlight = false;
          await _tokenManager.clearAll();
          getIt<NavigationService>().navigateAndRemoveUntil(
            AppRoutes.phoneNumber,
            arguments: {'message': 'Session expired. Please log in again.'},
          );
          return;
        }

        // Non-auth connect error — propagate to stream so Cubits can show an
        // error state, but only once per disconnect streak (not on every
        // backoff retry) so listeners don't get flooded while offline.
        if (!isAuthError &&
            _consecutiveConnectErrors == 1 &&
            _controller != null &&
            !_controller!.isClosed) {
          _controller!.addError(
            Exception('Socket connection error: $err'),
          );
        }
      } catch (e) {
        _logger.e('[PresenceSocket] Error in connect_error handler: $e');
      }
    });


    _socket!.on(_SocketEvents.disconnect, (reason) {
      try {
        _logger.w('[PresenceSocket] Disconnected — reason: $reason');
      } catch (e) {
        // Safe guard against callback errors
      }
    });
  }
}
