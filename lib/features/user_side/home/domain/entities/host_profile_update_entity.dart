import 'package:equatable/equatable.dart';

/// A `profile_updated` push for one user. Null fields didn't change.
class HostProfileUpdateEntity extends Equatable {
  final String userId;
  final String? avatarUrl;
  final String? fullName;

  const HostProfileUpdateEntity({
    required this.userId,
    this.avatarUrl,
    this.fullName,
  });

  @override
  List<Object?> get props => [userId, avatarUrl, fullName];
}
