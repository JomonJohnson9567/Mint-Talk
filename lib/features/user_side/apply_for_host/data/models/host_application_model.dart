import '../../domain/entities/host_application_entity.dart';

class HostApplicationModel extends HostApplicationEntity {
  const HostApplicationModel({
    required super.name,
    required super.dob,
    required super.bio,
    required super.selfieUrl,
  });

  factory HostApplicationModel.fromEntity(HostApplicationEntity entity) {
    return HostApplicationModel(
      name: entity.name,
      dob: entity.dob,
      bio: entity.bio,
      selfieUrl: entity.selfieUrl,
    );
  }

  factory HostApplicationModel.fromJson(Map<String, dynamic> json) {
    return HostApplicationModel(
      name: json['name'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      selfieUrl: json['selfieUrl'] as String? ?? json['selfie'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dob': dob,
      'bio': bio,
      'selfieUrl': selfieUrl,
    };
  }
}
