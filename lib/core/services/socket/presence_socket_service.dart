import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:mint_talk/config/env/env_config.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/services/session/session_manager.dart';
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
  static const String callActive = 'call_active';
  static const String subscribeCall = 'subscribe_call';
  static const String unsubscribeCall = 'unsubscribe_call';

  // Notifications
  static const String newNotification = 'new_notification';

  // Chat
  static const String newChatMessage = 'new_message';

  static const String visibilityUpdated = 'visibility_updated';
  static const String profileUpdated = 'profile_updated';
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
  StreamController<Map<String, dynamic>>? _visibilityController;
  StreamController<Map<String, dynamic>>? _profileController;
  StreamController<bool>? _connectionStatusController;

  /// Last value pushed to [connectionStatus] — lets [_emitConnectionStatus]
  /// drop no-op repeats (e.g. one per backoff retry while offline) so
  /// listeners only ever see real transitions.
  bool _lastConnectionStatus = false;

  /// Buffered availability update — flushed automatically on the next connect.
  bool? _pendingAudioAvailable;
  bool? _pendingVideoAvailable;

  /// Call IDs the app has asked the server to push events for. Unlike
  /// [updateAvailability] (buffered) or [subscribeFavorites] (re-emitted on
  /// every connect handler run), a plain emit()-on-connected subscribeCall
  /// only reaches the server if the socket happens to already be connected
  /// at the moment it's called — and any reconnect (screen off, a brief
  /// network drop, both routine mid-call) creates a new server-side socket
  /// session that has never subscribed to this callId, so server-pushed
  /// events like `call_ended` silently stop arriving for the rest of the
  /// call. Tracking the active set here and replaying subscribe_call for
  /// each one on every successful connect closes that gap.
  final Set<String> _subscribedCallIds = {};

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

  /// Caps the auth-refresh-and-reconnect path below — a safety net against
  /// an unbounded refresh→reconnect→fail loop if the socket server ever
  /// keeps rejecting a freshly refreshed token (backend bug, clock skew).
  /// Once the cap is hit, the socket gives up quietly rather than forcing a
  /// logout: a socket-only rejection isn't proof the REST session is dead.
  ///
  /// Note: the repeated "REST works, socket rejects" failures seen earlier
  /// were NOT a backend race — the socket was reusing the first token ever
  /// connected with (socket_io_client Manager/Socket caching). That's fixed
  /// by `enableForceNew()` + `setAuthFn` in [_createAndConnect].
  static const int _maxAuthRefreshAttempts = 3;

  /// True after the app itself asked for the socket to be down
  /// ([disconnect]/[dispose]: go offline, forced logout, dev-mode block).
  /// Cleared by the next [connect]. Keeps [isStalled] false so auto-recovery
  /// never fights an intentional disconnect.
  bool _clientDisconnected = false;
  int _authRefreshAttempts = 0;

  PresenceSocketService(this._envConfig, this._tokenManager);

  @override
  Stream<HostPresenceEntity> get presenceUpdates {
    _controller ??= StreamController<HostPresenceEntity>.broadcast();
    return _controller!.stream;
  }

  @override
  Stream<Map<String, dynamic>> get incomingCalls {
    _incomingCallController ??=
        StreamController<Map<String, dynamic>>.broadcast();
    return _incomingCallController!.stream;
  }

  @override
  Stream<Map<String, dynamic>> get callStatusUpdates {
    _callStatusController ??=
        StreamController<Map<String, dynamic>>.broadcast();
    return _callStatusController!.stream;
  }

  @override
  Stream<Map<String, dynamic>> get newNotifications {
    _newNotificationController ??=
        StreamController<Map<String, dynamic>>.broadcast();
    return _newNotificationController!.stream;
  }

  @override
  Stream<Map<String, dynamic>> get newChatMessages {
    _newChatMessageController ??=
        StreamController<Map<String, dynamic>>.broadcast();
    return _newChatMessageController!.stream;
  }

  @override
  Stream<Map<String, dynamic>> get visibilityUpdates {
    _visibilityController ??=
        StreamController<Map<String, dynamic>>.broadcast();
    return _visibilityController!.stream;
  }

  @override
  Stream<Map<String, dynamic>> get profileUpdates {
    _profileController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _profileController!.stream;
  }

  @override
  Stream<bool> get connectionStatus {
    _connectionStatusController ??= StreamController<bool>.broadcast();
    return _connectionStatusController!.stream;
  }

  @override
  bool get isConnected => _socket?.connected ?? false;

  @override
  bool get isStalled {
    if (isConnected || _clientDisconnected) return false;
    if (_connectInFlight || _isReconnecting) return false;
    // `active` stays true while the Manager is backing off after a
    // transport drop; it goes false once the socket is destroyed (server
    // disconnect, CONNECT_ERROR), after which nothing retries on its own.
    return _socket == null || !_socket!.active;
  }

  /// Pushes a connection-status transition, dropping repeats of the same
  /// value (e.g. one connect_error per backoff retry while offline).
  void _emitConnectionStatus(bool connected) {
    if (_lastConnectionStatus == connected) return;
    _lastConnectionStatus = connected;
    if (_connectionStatusController != null &&
        !_connectionStatusController!.isClosed) {
      _connectionStatusController!.add(connected);
    }
  }

  @override
  void connect(String accessToken) {
    // Ensure the stream controllers are alive before registering listeners.
    if (_controller == null || _controller!.isClosed) {
      _controller = StreamController<HostPresenceEntity>.broadcast();
    }
    if (_incomingCallController == null || _incomingCallController!.isClosed) {
      _incomingCallController =
          StreamController<Map<String, dynamic>>.broadcast();
    }
    if (_callStatusController == null || _callStatusController!.isClosed) {
      _callStatusController =
          StreamController<Map<String, dynamic>>.broadcast();
    }
    if (_newNotificationController == null ||
        _newNotificationController!.isClosed) {
      _newNotificationController =
          StreamController<Map<String, dynamic>>.broadcast();
    }
    if (_newChatMessageController == null ||
        _newChatMessageController!.isClosed) {
      _newChatMessageController =
          StreamController<Map<String, dynamic>>.broadcast();
    }
    if (_visibilityController == null || _visibilityController!.isClosed) {
      _visibilityController =
          StreamController<Map<String, dynamic>>.broadcast();
    }
    if (_profileController == null || _profileController!.isClosed) {
      _profileController = StreamController<Map<String, dynamic>>.broadcast();
    }
    if (_connectionStatusController == null ||
        _connectionStatusController!.isClosed) {
      _connectionStatusController = StreamController<bool>.broadcast();
    }

    _clientDisconnected = false;

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

  /// The freshest access token available — the in-memory one TokenManager
  /// holds after any refresh, falling back to the token this socket was
  /// created with.
  String _currentToken(String fallback) {
    final latest = _tokenManager.getAccessToken();
    return (latest != null && latest.isNotEmpty) ? latest : fallback;
  }

  void _createAndConnect(String accessToken) {
    _socket = io.io(
      _envConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          // REQUIRED: without forceNew, socket_io_client's io() returns the
          // cached Manager for this host (our URL has no path, so its
          // same-namespace check never matches) and that Manager hands back
          // the *same* Socket object from its nsps map — dispose() doesn't
          // remove it. Every "recreate with a new token" then silently
          // reused the very first token's auth + headers, so once that
          // token expired no refresh could ever get the socket back in.
          .enableForceNew()
          // Evaluated on every (re)connect handshake, so the socket's own
          // reconnection loop always presents the latest token rather than
          // the one captured at creation time.
          .setAuthFn((callback) {
            final token = _currentToken(accessToken);
            callback({'token': token, 'auth': token});
          })
          .setExtraHeaders({'Authorization': 'Bearer $accessToken'})
          // Graceful exponential backoff instead of hammering the network
          // every ~1s while the phone is asleep / briefly offline (which is
          // what produced the repeated "Failed host lookup" log spam) — but
          // capped well under the backend's own 15s grace period for an
          // active call (per the API docs: the server force-ends an active
          // call if this socket doesn't reconnect within 15s, independent
          // of whether Agora's own media connection is still healthy). The
          // previous 20s ceiling could let the gap between two reconnect
          // attempts exceed that window after only a couple of failures —
          // e.g. a video call's heavier bandwidth/CPU use getting briefly
          // throttled while backgrounded — silently losing an otherwise-
          // fine call to the server's own watchdog, not Agora's. 1s/8s
          // keeps every retry gap comfortably inside the 15s budget.
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(8000)
          .setRandomizationFactor(0.5)
          .build(),
    );
    // The Manager builds a fresh engine from its options on every reconnect
    // attempt, so refreshing the header here keeps it in step with the auth
    // payload above.
    _socket!.io.on('reconnect_attempt', (_) {
      final options = _socket?.io.options;
      if (options != null) {
        options['extraHeaders'] = {
          'Authorization': 'Bearer ${_currentToken(accessToken)}',
        };
      }
    });
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
  void requestPresenceSnapshot() => _requestSnapshot();

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
    _subscribedCallIds.add(callId);
    if (_socket != null && _socket!.connected) {
      _logger.d('[PresenceSocket] Emitting subscribe_call for callId: $callId');
      _socket!.emit(_SocketEvents.subscribeCall, {'callId': callId});
    }
    // If not connected yet, the connect handler below flushes it once the
    // handshake completes — and re-flushes it again on every reconnect.
  }

  @override
  void unsubscribeCall(String callId) {
    _subscribedCallIds.remove(callId);
    if (_socket != null && _socket!.connected) {
      _logger.d(
        '[PresenceSocket] Emitting unsubscribe_call for callId: $callId',
      );
      _socket!.emit(_SocketEvents.unsubscribeCall, {'callId': callId});
    }
  }

  @override
  void disconnect() {
    _logger.d('[PresenceSocket] Disconnecting.');
    _clientDisconnected = true;
    _connectInFlight = false;
    _socket?.disconnect();
  }

  @override
  void dispose() {
    _logger.d('[PresenceSocket] Disposing.');
    _clientDisconnected = true;
    _connectInFlight = false;
    _subscribedCallIds.clear();
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
    _visibilityController?.close();
    _visibilityController = null;
    _profileController?.close();
    _profileController = null;
    _connectionStatusController?.close();
    _connectionStatusController = null;
    _lastConnectionStatus = false;
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
        _emitConnectionStatus(true);

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

        // Re-subscribe to every call still in progress — a fresh reconnect
        // is a brand new server-side socket session that has no memory of
        // subscribe_call requests made before the drop, so without this a
        // reconnect mid-call (screen off, brief network blip) silently cuts
        // off server-pushed events (call_ended, etc.) for the rest of the
        // call.
        for (final callId in _subscribedCallIds) {
          _logger.d('[PresenceSocket] Re-subscribing to call: $callId');
          _socket!.emit(_SocketEvents.subscribeCall, {'callId': callId});
        }
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
              _logger.w(
                '   → skipped non-Map list element: ${item.runtimeType} = $item',
              );
            }
          }
        } else if (data is Map) {
          _logger.d('   → payload is a Map, checking for nested list keys');
          final rawList = data['hosts'] ?? data['items'] ?? data['data'];
          if (rawList is List) {
            _logger.d(
              '   → found nested list under key, length=${rawList.length}',
            );
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
        _logger.e(
          '[PresenceSocket] Failed to parse host_status_update: $e\n$st',
        );
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

    _socket!.on(_SocketEvents.visibilityUpdated, (data) {
      _logger.i('🙈 [PresenceSocket] visibility_updated received: $data');
      if (data is Map &&
          _visibilityController != null &&
          !_visibilityController!.isClosed) {
        _visibilityController!.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on(_SocketEvents.profileUpdated, (data) {
      _logger.i('🖼️ [PresenceSocket] profile_updated received: $data');
      if (data is Map &&
          _profileController != null &&
          !_profileController!.isClosed) {
        _profileController!.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on(_SocketEvents.callStatusUpdated, _handleCallStatusData);
    _socket!.on(_SocketEvents.callStatusUpdate, _handleCallStatusData);
    _socket!.on(_SocketEvents.callAccepted, (data) {
      final mapData = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};
      mapData['status'] = 'accepted';
      _handleCallStatusData(mapData);
    });
    // Both participants' /activate calls have landed and the server has
    // started billing — the authoritative "call is live" signal.
    _socket!.on(_SocketEvents.callActive, (data) {
      final mapData = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};
      mapData['status'] = 'active';
      _handleCallStatusData(mapData);
    });
    // An accepted call that never activated ends with status `failed`
    // (endReason `connection_timeout`) — keep that rather than forcing
    // `ended`, so the UI shows "Could not connect" instead of a summary.
    _socket!.on('call_ended', (data) {
      final mapData = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};
      if (mapData['status']?.toString() != 'failed') {
        mapData['status'] = 'ended';
      }
      _handleCallStatusData(mapData);
    });
    _socket!.on('call_rejected', (data) {
      final mapData = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};
      mapData['status'] = 'rejected';
      _handleCallStatusData(mapData);
    });
    _socket!.on('call_missed', (data) {
      final mapData = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};
      mapData['status'] = 'missed';
      _handleCallStatusData(mapData);
    });
    _socket!.on('call_cancelled', (data) {
      final mapData = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};
      mapData['status'] = 'cancelled';
      _handleCallStatusData(mapData);
    });
    _socket!.on('call_insufficient_balance', (data) {
      final mapData = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};
      mapData['status'] = 'insufficient_balance';
      _handleCallStatusData(mapData);
    });

    // Backend pushes this to the old device when the account logs in on
    // another phone. SessionManager disconnects this socket (so it doesn't
    // auto-reconnect with the revoked token), clears credentials, and shows
    // the server's message on the login screen.
    _socket!.on(_SocketEvents.sessionTerminated, (data) async {
      try {
        final raw = data is Map ? data['message'] : data;
        final text = raw?.toString().trim() ?? '';
        final message = text.isNotEmpty
            ? text
            : SessionManager.sessionTerminatedMessage;
        _logger.w('[PresenceSocket] Session terminated: $message');
        await getIt<SessionManager>().forceLogout(message: message);
      } catch (e) {
        _logger.e('[PresenceSocket] Error handling session_terminated: $e');
      }
    });

    _socket!.on(_SocketEvents.connectError, (err) async {
      try {
        final errMsg = err?.toString() ?? '';
        _consecutiveConnectErrors++;
        _emitConnectionStatus(false);

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
            '(attempt #$_consecutiveConnectErrors): $err',
          );
        }

        // Detect authentication / token expiry errors and attempt refresh + reconnect.
        // Auth errors should NOT be propagated to the stream as fatal errors —
        // the app should silently refresh the token and reconnect instead.
        final isAuthError =
            errMsg.toLowerCase().contains('auth') ||
            errMsg.toLowerCase().contains('expired') ||
            errMsg.toLowerCase().contains('session') ||
            errMsg.toLowerCase().contains('token') ||
            errMsg.toLowerCase().contains('unauthorized');

        if (isAuthError && !_isReconnecting) {
          if (_authRefreshAttempts >= _maxAuthRefreshAttempts) {
            // The refreshed token has failed at the socket layer
            // _maxAuthRefreshAttempts times in a row while the same token
            // keeps working for REST — refreshing again isn't going to fix
            // it, but the REST session is demonstrably still valid, so
            // forcing a logout would be wrong. Give up on the real-time
            // channel only: presence/call-signaling goes stale until the
            // next explicit connect() (next screen visit, pull-to-refresh,
            // app resume), and the retry budget resets for that attempt.
            _logger.e(
              '[PresenceSocket] Auth refresh retry limit reached '
              '($_maxAuthRefreshAttempts attempts) — giving up on the '
              'socket without logging out; REST session may still be valid.',
            );
            _authRefreshAttempts = 0;
            _isReconnecting = false;
            _connectInFlight = false;
            _socket?.disconnect();
            return;
          }

          _authRefreshAttempts++;
          _isReconnecting = true;
          _logger.w(
            '[PresenceSocket] Auth error — attempting token refresh & reconnect '
            '(attempt $_authRefreshAttempts/$_maxAuthRefreshAttempts)...',
          );

          final result = await _tokenManager.refreshAccessToken();
          if (result == RefreshResult.success) {
            final newToken = _tokenManager.getAccessToken();
            if (newToken != null && newToken.isNotEmpty) {
              // Give the backend a moment to settle before reconnecting —
              // reconnecting instantly after a refresh can hit the exact
              // same "session expired" rejection if the server's session
              // store hasn't finished propagating the refresh yet, burning
              // through the retry budget on a race rather than a real
              // failure. Backs off a little more on each attempt.
              await Future.delayed(Duration(seconds: _authRefreshAttempts));
              _logger.i(
                '[PresenceSocket] Token refreshed — reconnecting socket...',
              );
              _socket?.dispose();
              _socket = null;
              _isReconnecting = false;
              _createAndConnect(newToken);
              return;
            }
          }

          _isReconnecting = false;
          _connectInFlight = false;

          if (result == RefreshResult.rejected) {
            // Refresh refused (e.g. 403 after a login on another device) —
            // the session is over.
            _logger.e(
              '[PresenceSocket] Token refresh rejected — session ended. Logging out.',
            );
            await getIt<SessionManager>().forceLogout(
              message: SessionManager.sessionExpiredMessage,
            );
            return;
          }

          // Refresh couldn't reach the server (offline / timeout / 5xx).
          // That's not proof the session is gone, so stay logged in and
          // leave the socket down; the next connect() (screen visit, app
          // resume) tries again.
          _logger.w(
            '[PresenceSocket] Token refresh failed transiently — keeping the '
            'session; socket will retry on the next connect().',
          );
          _socket?.disconnect();
          return;
        }

        // A CONNECT_ERROR packet (server middleware rejected the handshake)
        // makes socket_io_client destroy() this socket. The Manager will not
        // retry it, unlike a transport error, where the socket stays
        // `active` and the backoff loop keeps going. Without clearing the
        // in-flight latch here, every later connect() (Ready, Reconnect)
        // would be dropped as a "duplicate" and the host would stay offline
        // until the app restarted. Clearing it lets the next connect()
        // build a fresh socket.
        if (!_isReconnecting && _socket != null && !_socket!.active) {
          _connectInFlight = false;
          _logger.w(
            '[PresenceSocket] Server rejected handshake ($err) — not '
            'auto-retrying; the next connect() will recreate the socket.',
          );
        }

        // Non-auth connect error — propagate to stream so Cubits can show an
        // error state, but only once per disconnect streak (not on every
        // backoff retry) so listeners don't get flooded while offline.
        if (!isAuthError &&
            _consecutiveConnectErrors == 1 &&
            _controller != null &&
            !_controller!.isClosed) {
          _controller!.addError(Exception('Socket connection error: $err'));
        }
      } catch (e) {
        _logger.e('[PresenceSocket] Error in connect_error handler: $e');
      }
    });

    _socket!.on(_SocketEvents.disconnect, (reason) {
      try {
        _logger.w('[PresenceSocket] Disconnected — reason: $reason');
        _emitConnectionStatus(false);
      } catch (e) {
        // Safe guard against callback errors
      }
    });
  }
}
