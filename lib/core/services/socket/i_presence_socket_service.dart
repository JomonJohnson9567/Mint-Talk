import 'package:mint_talk/features/user_side/home/domain/entities/host_presence_entity.dart';

/// Abstract interface for the Socket.io presence & call-event service.
///
/// Responsibility split:
///  - **Presence** : receives real-time host online/busy status updates.
///  - **Call events**: receives server-pushed call lifecycle events
///    (incoming_call, call_accepted, call_active, call_ended, etc.).
///
/// ⚠️ This service is a READ-ONLY consumer of server-pushed events.
///    All call STATE CHANGES (initiate, accept, reject, cancel, end) are
///    performed via HTTP REST endpoints (ICallRepository / use cases).
///    Socket is never used to emit call actions from the client.
abstract class IPresenceSocketService {
  /// Continuous stream of host presence events.
  Stream<HostPresenceEntity> get presenceUpdates;

  /// Stream of incoming call payloads — consumed by the host-side overlay.
  Stream<Map<String, dynamic>> get incomingCalls;

  /// Stream of call status events for an active/subscribed call.
  /// Consumed by [CallRepositoryImpl] which maps raw payloads → [CallSocketEvent].
  Stream<Map<String, dynamic>> get callStatusUpdates;

  /// Stream of raw notification payloads pushed the moment a new
  /// notification is dispatched to the logged-in user.
  Stream<Map<String, dynamic>> get newNotifications;

  /// Stream of raw chat-message payloads pushed the moment a new message is
  /// sent in any conversation the logged-in user is a participant in —
  /// scoped server-side to the authenticated socket session, same as
  /// [newNotifications] (no per-conversation subscribe call needed).
  Stream<Map<String, dynamic>> get newChatMessages;

  /// Opens the socket connection with the given [accessToken].
  void connect(String accessToken);

  /// Asks the server to re-push a full presence snapshot (one
  /// [host_status_update]/[presence_update] event per online/busy host).
  ///
  /// Live incremental broadcasts can be missed by an already-connected
  /// socket (e.g. a backend-side broadcast gap right after another host's
  /// mid-session `update_availability`, as opposed to their connect/
  /// disconnect events, which reliably re-sync). This gives callers a way
  /// to force a manual re-sync — e.g. on pull-to-refresh — instead of the
  /// only other reliable recovery being a full socket reconnect. No-op if
  /// the socket isn't currently connected.
  void requestPresenceSnapshot();

  /// Emits availability status update to the server (staff/host only).
  void updateAvailability({
    required bool audioAvailable,
    required bool videoAvailable,
  });

  /// Tells the server to include the user's favorited hosts in the
  /// [presenceUpdates] push channel. Safe to call whenever the socket is
  /// connected — re-emitted automatically on every reconnect.
  void subscribeFavorites();

  /// Tells the server to push call events for [callId] to this socket.
  /// Safe to call whenever the socket is connected — re-emitted
  /// automatically on every reconnect for as long as the call stays
  /// subscribed (i.e. until [unsubscribeCall] is called for it).
  void subscribeCall(String callId);

  /// Tells the server to stop pushing call events for [callId] to this socket.
  void unsubscribeCall(String callId);

  /// Gracefully closes the socket connection.
  void disconnect();

  /// Permanently closes stream controllers and destroys the socket.
  void dispose();
}

