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

  // Call signaling events
  static const String incomingCall = 'incoming_call';
  static const String callStatusUpdated = 'call_status_updated';
  static const String callStatusUpdate = 'call_status_update';
  static const String callAccepted = 'call_accepted';
  static const String subscribeCall = 'subscribe_call';
  static const String unsubscribeCall = 'unsubscribe_call';
  static const String initiateCall = 'initiate_call';
  static const String acceptCall = 'accept_call';
  static const String rejectCall = 'reject_call';
  static const String cancelCall = 'cancel_call';
  static const String endCall = 'end_call';
}

/// Concrete implementation of [IPresenceSocketService] using `socket_io_client`.
@LazySingleton(as: IPresenceSocketService)
class PresenceSocketService implements IPresenceSocketService {
  final EnvConfig _envConfig;
  final Logger _logger = Logger();

  io.Socket? _socket;
  StreamController<HostPresenceEntity>? _controller;
  StreamController<Map<String, dynamic>>? _incomingCallController;
  StreamController<Map<String, dynamic>>? _callStatusController;

  /// Buffered availability update — flushed automatically on the next connect.
  /// Set when [updateAvailability] is called before the socket handshake
  /// completes, so the intent is never silently dropped.
  bool? _pendingAudioAvailable;
  bool? _pendingVideoAvailable;

  PresenceSocketService(this._envConfig);

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
  void connect(String accessToken) {
    // Ensure the stream controller is alive before registering any listeners.
    if (_controller == null || _controller!.isClosed) {
      _controller = StreamController<HostPresenceEntity>.broadcast();
    }

    if (_socket != null) {
      if (_socket!.connected) {
        _logger.d(
          '[PresenceSocket] Already connected — requesting snapshot immediately.',
        );
        _requestSnapshot();
        return;
      }
      _logger.d('[PresenceSocket] Re-creating socket connection...');
      _socket!.dispose();
      _socket = null;
    }

    _logger.d('[PresenceSocket] Connecting to ${_envConfig.socketUrl}');

    _socket = io.io(
      _envConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': accessToken, 'auth': accessToken})
          .setExtraHeaders({'Authorization': 'Bearer $accessToken'})
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
  void emitInitiateCall({
    required String hostId,
    required String callType,
  }) {
    if (_socket != null && _socket!.connected) {
      _logger.d('[PresenceSocket] Emitting initiate_call for hostId: $hostId, type: $callType');
      _socket!.emit(_SocketEvents.initiateCall, {
        'hostId': hostId,
        'callType': callType,
      });
    } else {
      _logger.w('[PresenceSocket] Socket not connected when attempting emitInitiateCall');
    }
  }

  @override
  void emitAcceptCall(String callId) {
    if (_socket != null && _socket!.connected) {
      _logger.d('[PresenceSocket] Emitting accept_call for callId: $callId');
      _socket!.emit(_SocketEvents.acceptCall, {'callId': callId});
    }
  }

  @override
  void emitRejectCall(String callId) {
    if (_socket != null && _socket!.connected) {
      _logger.d('[PresenceSocket] Emitting reject_call for callId: $callId');
      _socket!.emit(_SocketEvents.rejectCall, {'callId': callId});
    }
  }

  @override
  void emitCancelCall(String callId) {
    if (_socket != null && _socket!.connected) {
      _logger.d('[PresenceSocket] Emitting cancel_call for callId: $callId');
      _socket!.emit(_SocketEvents.cancelCall, {'callId': callId});
    }
  }

  @override
  void emitEndCall(String callId) {
    if (_socket != null && _socket!.connected) {
      _logger.d('[PresenceSocket] Emitting end_call for callId: $callId');
      _socket!.emit(_SocketEvents.endCall, {'callId': callId});
    }
  }

  @override
  void disconnect() {
    _logger.d('[PresenceSocket] Disconnecting.');
    _socket?.disconnect();
  }

  @override
  void dispose() {
    _logger.d('[PresenceSocket] Disposing.');
    _socket?.dispose();
    _socket = null;
    _controller?.close();
    _controller = null;
    _incomingCallController?.close();
    _incomingCallController = null;
    _callStatusController?.close();
    _callStatusController = null;
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

    _socket!.on(_SocketEvents.connectError, (err) {
      try {
        _logger.e('[PresenceSocket] Connection error: $err');
        if (_controller != null && !_controller!.isClosed) {
          _controller!.addError(
            Exception('Socket connection error: $err'),
          );
        }
      } catch (e) {
        // Safe guard against callback errors
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
