import 'package:mint_talk/features/auth/domain/entities/user_entity.dart';

/// Data model extending [UserEntity] with JSON serialization.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phone,
    required super.role,
    required super.profileCompleted,
    super.fullName,
    super.gender,
    super.dob,
    super.referralCode,
    super.avatarUrl,
    super.audioRate,
    super.videoRate,
    super.isAudioAllowed,
    super.isVideoAllowed,
    super.termsAcceptedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      profileCompleted: json['profileCompleted'] as bool? ?? false,
      fullName: json['fullName'] as String?,
      gender: json['gender'] as String?,
      dob: json['dob'] as String?,
      referralCode: json['referralCode'] as String?,
      avatarUrl: (json['avatarUrl'] ??
              json['avatar_url'] ??
              json['avatar'] ??
              json['profileImagePath'] ??
              json['profile_image_path'])
          ?.toString(),
      audioRate: _intFromJson(json['audioRate']),
      videoRate: _intFromJson(json['videoRate']),
      isAudioAllowed: json['isAudioAllowed'] as bool?,
      isVideoAllowed: json['isVideoAllowed'] as bool?,
      termsAcceptedAt: json['termsAcceptedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'phone': phone,
      'role': role,
      'profileCompleted': profileCompleted,
      'fullName': fullName,
      'gender': gender,
      'dob': dob,
      'referralCode': referralCode,
      'avatarUrl': avatarUrl,
      'audioRate': audioRate,
      'videoRate': videoRate,
      'isAudioAllowed': isAudioAllowed,
      'isVideoAllowed': isVideoAllowed,
      'termsAcceptedAt': termsAcceptedAt,
    };
  }

  static int? _intFromJson(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
