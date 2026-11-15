import 'dart:async';

import 'package:injectable/injectable.dart';

/// App-wide set of user IDs the signed-in user has blocked.
///
/// The backend doesn't filter blocked hosts out of the host list, favorites
/// or presence events, so every host list has to filter them itself. Several
/// `HomeCubit` instances live at once (home, audio- and video-call hosts
/// screens), so the set lives here rather than in any one cubit.
///
/// Kept in sync by `BlockRepositoryImpl` on every successful fetch, block
/// and unblock; cleared by `SessionManager` on logout.
///
/// Also holds hosts the server hid from this user via `visibility_updated`
/// (`visible: false`, e.g. the host blocked them) — kept apart from [ids] so
/// a block-list refetch ([replaceAll]) can't un-hide them.
@lazySingleton
class BlockedHostsStore {
  final Set<String> _ids = {};
  final Set<String> _hiddenByServer = {};
  final StreamController<Set<String>> _controller =
      StreamController<Set<String>>.broadcast();

  Set<String> get ids => Set.unmodifiable(_ids);

  /// Emits the full set after every change.
  Stream<Set<String>> get changes => _controller.stream;

  /// True when the host must be left out of every list: blocked by this
  /// user, or hidden by the server.
  bool isBlocked(String id) => _ids.contains(id) || _hiddenByServer.contains(id);

  /// Applies a `visibility_updated` event for [id].
  void setServerVisibility(String id, {required bool visible}) {
    if (id.isEmpty) return;
    final changed = visible ? _hiddenByServer.remove(id) : _hiddenByServer.add(id);
    if (changed) _notify();
  }

  void replaceAll(Iterable<String> ids) {
    final next = ids.where((id) => id.isNotEmpty).toSet();
    if (next.length == _ids.length && next.containsAll(_ids)) return;
    _ids
      ..clear()
      ..addAll(next);
    _notify();
  }

  void add(String id) {
    if (id.isNotEmpty && _ids.add(id)) _notify();
  }

  void remove(String id) {
    if (_ids.remove(id)) _notify();
  }

  void clear() {
    if (_ids.isEmpty && _hiddenByServer.isEmpty) return;
    _ids.clear();
    _hiddenByServer.clear();
    _notify();
  }

  void _notify() => _controller.add(ids);
}
