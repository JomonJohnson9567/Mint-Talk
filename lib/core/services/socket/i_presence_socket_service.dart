import 'package:mint_talk/features/user_side/home/domain/entities/host_presence_entity.dart';

/// Abstract interface for the Socket.io presence service.
///
/// Exposes a continuous [presenceUpdates] stream that emits:
/// - An initial burst of [HostPresenceEntity] events sent by the server
///   immediately after the socket connects (full presence snapshot).
/// - Subsequent real-time patch events whenever a host status changes.
///
/// The user-side app is a **read-only consumer** — it never emits socket events.
abstract class IPresenceSocketService {
  /// Continuous stream of host presence events.
  Stream<HostPresenceEntity> get presenceUpdates;

  /// Continuous stream of incoming calls for host users.
  Stream<Map<String, dynamic>> get incomingCalls;

  /// Continuous stream of call status changes for an active/subscribed call.
  Stream<Map<String, dynamic>> get callStatusUpdates;

  /// Opens the socket connection with the given [accessToken].
  void connect(String accessToken);

  /// Emits availability status update to the server (staff/host only).
  void updateAvailability({
    required bool audioAvailable,
    required bool videoAvailable,
  });

  /// Subscribes socket to real-time events for a specific [callId].
  void subscribeCall(String callId);

  /// Unsubscribes socket from real-time events for a specific [callId].
  void unsubscribeCall(String callId);

  /// Emits an initiate call request via socket.
  void emitInitiateCall({
    required String hostId,
    required String callType,
  });

  /// Emits accept call event via socket.
  void emitAcceptCall(String callId);

  /// Emits reject call event via socket.
  void emitRejectCall(String callId);

  /// Emits cancel call event via socket.
  void emitCancelCall(String callId);

  /// Emits end call event via socket.
  void emitEndCall(String callId);

  /// Gracefully closes the socket connection.
  void disconnect();

  /// Permanently closes stream controllers and destroys the socket.
  void dispose();
}
