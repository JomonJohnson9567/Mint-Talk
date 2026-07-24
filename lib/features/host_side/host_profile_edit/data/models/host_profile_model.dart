import '../../domain/entities/host_profile_entity.dart';

/// Data Transfer Object (DTO) for Host Profile.
/// Extends the domain entity [HostProfileEntity] to support serialisation/deserialisation.
class HostProfileModel extends HostProfileEntity {
  const HostProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.idNumber,
    required super.dob,
    required super.selectedCategories,
    required super.avatarAsset,
  });

  factory HostProfileModel.fromJson(Map<String, dynamic> json) {
    return HostProfileModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      idNumber: json['idNumber'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
      selectedCategories: List<String>.from(json['selectedCategories'] ?? []),
      avatarAsset: json['avatarAsset'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'idNumber': idNumber,
      'dob': dob,
      'selectedCategories': selectedCategories,
      'avatarAsset': avatarAsset,
    };
  }

  factory HostProfileModel.fromEntity(HostProfileEntity entity) {
    return HostProfileModel(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      phone: entity.phone,
      idNumber: entity.idNumber,
      dob: entity.dob,
      selectedCategories: entity.selectedCategories,
      avatarAsset: entity.avatarAsset,
    );
  }
}
