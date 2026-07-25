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
    super.gender = 'female',
    super.termsAcceptedAt = '',
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
      gender: json['gender'] as String? ?? 'female',
      termsAcceptedAt: json['termsAcceptedAt'] as String? ?? '',
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
      'gender': gender,
      'termsAcceptedAt': termsAcceptedAt,
      'selectedCategories': selectedCategories,
      'avatarAsset': avatarAsset,
    };
  }

  /// Payload for editing an already-completed host profile.
  /// Formats fields for the /user/profile API endpoint.
  Map<String, dynamic> toUpdateJson() {
    final validGender = (gender.toLowerCase() == 'male' ||
            gender.toLowerCase() == 'female' ||
            gender.toLowerCase() == 'other')
        ? gender.toLowerCase()
        : 'female';

    final validTerms = termsAcceptedAt.isNotEmpty
        ? termsAcceptedAt
        : DateTime.now().toUtc().toIso8601String();

    final data = <String, dynamic>{
      'fullName': fullName,
      'gender': validGender,
      'termsAcceptedAt': validTerms,
    };
    if (dob.isNotEmpty) {
      data['dob'] = _formatDobForApi(dob);
    }
    if (email.isNotEmpty) {
      data['email'] = email;
    }
    if (selectedCategories.isNotEmpty) {
      data['categories'] = selectedCategories;
    }
    if (avatarAsset.isNotEmpty) {
      data['avatarAsset'] = avatarAsset;
    }
    return data;
  }

  static String _formatDobForApi(String rawDob) {
    if (rawDob.contains('/')) {
      final parts = rawDob.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
    }
    return rawDob;
  }

  factory HostProfileModel.fromEntity(HostProfileEntity entity) {
    return HostProfileModel(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      phone: entity.phone,
      idNumber: entity.idNumber,
      dob: entity.dob,
      gender: entity.gender,
      termsAcceptedAt: entity.termsAcceptedAt,
      selectedCategories: entity.selectedCategories,
      avatarAsset: entity.avatarAsset,
    );
  }
}

