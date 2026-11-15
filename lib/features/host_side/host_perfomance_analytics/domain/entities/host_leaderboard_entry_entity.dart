import 'package:equatable/equatable.dart';

/// One row of the weekly "Earning alongside you" host leaderboard.
class HostLeaderboardEntryEntity extends Equatable {
  final String name;
  final String avatarUrl;
  final int minutes;
  final double earningsInr;

  /// True for the signed-in host's own row.
  final bool isMe;

  const HostLeaderboardEntryEntity({
    required this.name,
    required this.avatarUrl,
    required this.minutes,
    required this.earningsInr,
    this.isMe = false,
  });

  @override
  List<Object?> get props => [name, avatarUrl, minutes, earningsInr, isMe];
}
