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
    };
  }
}
