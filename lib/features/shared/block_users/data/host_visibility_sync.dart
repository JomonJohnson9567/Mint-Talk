import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/features/shared/block_users/data/blocked_hosts_store.dart';

/// Feeds `visibility_updated` socket events into [BlockedHostsStore], which
/// every host list (discovery, favorites, online indicators) already
/// filters on. Started once for the app's lifetime from `main`; the socket
/// keeps this stream alive across disconnect/reconnect.
@lazySingleton
class HostVisibilitySync {
  final IPresenceSocketService _socket;
  final BlockedHostsStore _store;
  StreamSubscription<Map<String, dynamic>>? _sub;

  HostVisibilitySync(this._socket, this._store);

  void start() {
    _sub ??= _socket.visibilityUpdates.listen(handle);
  }

  /// Payload shape isn't fixed yet — accepts the likely id keys and a
  /// `visible` boolean; anything else is ignored.
  void handle(Map<String, dynamic> data) {
    final visible = data['visible'];
    final id =
        (data['hostId'] ??
                data['userId'] ??
                data['targetUserId'] ??
                data['id'] ??
                data['_id'])
            ?.toString() ??
        '';
    if (visible is! bool || id.isEmpty) {
      appLogger.w('HostVisibilitySync: ignoring malformed payload');
      return;
    }
    _store.setServerVisibility(id, visible: visible);
  }

  @disposeMethod
  void dispose() => _sub?.cancel();
}
