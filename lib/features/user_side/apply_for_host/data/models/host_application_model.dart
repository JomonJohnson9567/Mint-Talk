import '../../domain/entities/host_application_entity.dart';

class HostApplicationModel extends HostApplicationEntity {
  const HostApplicationModel({
    required super.name,
    required super.bio,
    required super.phone,
    required super.dob,
    required super.aadhaarNumber,
    required super.aadhaarFront,
    required super.aadhaarBack,
    required super.selfie,
  });

  factory HostApplicationModel.fromEntity(HostApplicationEntity entity) {
    return HostApplicationModel(
      name: entity.name,
      bio: entity.bio,
      phone: entity.phone,
      dob: entity.dob,
      aadhaarNumber: entity.aadhaarNumber,
      aadhaarFront: entity.aadhaarFront,
      aadhaarBack: entity.aadhaarBack,
      selfie: entity.selfie,
    );
  }

  factory HostApplicationModel.fromJson(Map<String, dynamic> json) {
    return HostApplicationModel(
      name: json['name'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
      aadhaarNumber: json['aadhaar_number'] as String? ?? '',
      aadhaarFront: json['aadhaar_front'] as String? ?? '',
      aadhaarBack: json['aadhaar_back'] as String? ?? '',
      selfie: json['selfie'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'phone': phone,
      'dob': dob,
      'aadhaar_number': aadhaarNumber,
      'aadhaar_front': aadhaarFront,
      'aadhaar_back': aadhaarBack,
      'selfie': selfie,
    };
  }
}
