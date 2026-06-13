import '../../domain/entities/host_application_entity.dart';

class HostApplicationModel extends HostApplicationEntity {
  const HostApplicationModel({
    required super.name,
    required super.bio,
    required super.phone,
    required super.dob,
  });

  factory HostApplicationModel.fromEntity(HostApplicationEntity entity) {
    return HostApplicationModel(
      name: entity.name,
      bio: entity.bio,
      phone: entity.phone,
      dob: entity.dob,
    );
  }

  factory HostApplicationModel.fromJson(Map<String, dynamic> json) {
    return HostApplicationModel(
      name: json['name'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'phone': phone,
      'dob': dob,
    };
  }
}
