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
