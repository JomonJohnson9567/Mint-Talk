import '../../domain/entities/host_application_status_entity.dart';

class HostApplicationStatusModel extends HostApplicationStatusEntity {
  const HostApplicationStatusModel({
    required super.id,
    required super.userId,
    required super.status,
    super.rejectionReason,
    super.kyc,
  });

  factory HostApplicationStatusModel.fromJson(Map<String, dynamic> json) {
    final kycJson = json['kyc'];
    return HostApplicationStatusModel(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      rejectionReason: json['rejectionReason']?.toString(),
      kyc: kycJson is Map<String, dynamic>
          ? HostKycStatusEntity(
              documentType: kycJson['documentType']?.toString() ?? '',
              documentNumber: kycJson['documentNumber']?.toString() ?? '',
              status: kycJson['status']?.toString().toLowerCase() ?? 'pending',
            )
          : null,
    );
  }
}
