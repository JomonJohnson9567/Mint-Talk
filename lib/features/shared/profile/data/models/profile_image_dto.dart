import '../../domain/entities/profile_image_entity.dart';

class ProfileImageDto {
  final String avatarUrl;

  const ProfileImageDto({required this.avatarUrl});

  factory ProfileImageDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    return ProfileImageDto(
      avatarUrl: (data['avatarUrl'] ?? '').toString(),
    );
  }

  ProfileImageEntity toEntity() {
    return ProfileImageEntity(avatarUrl: avatarUrl);
  }
}
