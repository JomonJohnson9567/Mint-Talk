import '../../domain/entities/blocked_user_entity.dart';

class BlockedUserDto {
  final String id;
  final String blockerId;
  final String blockedId;
  final String fullName;
  final String phone;
  final String role;
  final String avatarUrl;
  final DateTime? createdAt;

  const BlockedUserDto({
    required this.id,
    required this.blockerId,
    required this.blockedId,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.avatarUrl,
    this.createdAt,
  });

  factory BlockedUserDto.fromJson(Map<String, dynamic> json) {
    final blockedIdData = json['blockedId'];
    String blockedIdStr = '';
    String fullName = '';
    String phone = '';
    String role = '';
    String avatarUrl = '';

    if (blockedIdData is Map<String, dynamic>) {
      blockedIdStr = (blockedIdData['id'] ?? blockedIdData['_id'] ?? '').toString();
      fullName = (blockedIdData['fullName'] ?? '').toString();
      phone = (blockedIdData['phone'] ?? '').toString();
      role = (blockedIdData['role'] ?? '').toString();
      avatarUrl = (blockedIdData['avatarUrl'] ?? '').toString();
    } else if (blockedIdData is String) {
      blockedIdStr = blockedIdData;
    }

    return BlockedUserDto(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      blockerId: (json['blockerId'] ?? '').toString(),
      blockedId: blockedIdStr,
      fullName: fullName,
      phone: phone,
      role: role,
      avatarUrl: avatarUrl,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  BlockedUserEntity toEntity() {
    return BlockedUserEntity(
      id: id,
      blockerId: blockerId,
      blockedId: blockedId,
      fullName: fullName,
      phone: phone,
      role: role,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }
}
