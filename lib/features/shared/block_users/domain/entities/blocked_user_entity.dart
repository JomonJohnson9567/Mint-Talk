import 'package:equatable/equatable.dart';

class BlockedUserEntity extends Equatable {
  final String id;
  final String blockerId;
  final String blockedId;
  final String fullName;
  final String phone;
  final String role;
  final String avatarUrl;
  final DateTime? createdAt;

  const BlockedUserEntity({
    required this.id,
    required this.blockerId,
    required this.blockedId,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.avatarUrl,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        blockerId,
        blockedId,
        fullName,
        phone,
        role,
        avatarUrl,
        createdAt,
      ];
}
