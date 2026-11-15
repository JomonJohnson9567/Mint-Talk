import 'package:equatable/equatable.dart';

class HostPresenceEntity extends Equatable {
  final String userId;
  final String role;
  final String status;
  final int lastSeen;
  final int updatedAt;
  final bool busy;
  final bool audioAvailable;
  final bool videoAvailable;
  final String state;

  const HostPresenceEntity({
    required this.userId,
    required this.role,
    required this.status,
    required this.lastSeen,
    required this.updatedAt,
    required this.busy,
    required this.audioAvailable,
    required this.videoAvailable,
    required this.state,
  });

  /// Whether this host can actually be called right now.
  ///
  /// `status == 'online'` only means the host's presence socket is
  /// connected — it flips true the moment their dashboard opens, before
  /// they've tapped "Ready". A host is only truly callable once they've
  /// also opted in via `audioAvailable`/`videoAvailable`. This is the single
  /// source of truth for that check so call-gating logic doesn't drift
  /// between the host grid, profile screen, and tab filters.
  bool get isAvailableForCalls =>
      status == 'online' && !isOnCall && (audioAvailable || videoAvailable);

  /// Whether this host is currently in a call.
  ///
  /// A disconnected host is never "on call": a stale `state: busy` or
  /// `busy: true` can outlive the host's socket, so `status` is checked
  /// first. While connected, the backend's derived `state` is authoritative
  /// when present, falling back to the raw `busy` flag.
  bool get isOnCall {
    if (status != 'online') return false;
    if (state.isNotEmpty) return state == 'busy';
    return busy;
  }

  @override
  List<Object?> get props => [
    userId,
    role,
    status,
    lastSeen,
    updatedAt,
    busy,
    audioAvailable,
    videoAvailable,
    state,
  ];
}
