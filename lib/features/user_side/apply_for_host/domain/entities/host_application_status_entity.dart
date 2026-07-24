import 'package:equatable/equatable.dart';

class HostApplicationStatusEntity extends Equatable {
  final String id;
  final String userId;
  final String status;
  final String? rejectionReason;
  final HostKycStatusEntity? kyc;

  const HostApplicationStatusEntity({
    required this.id,
    required this.userId,
    required this.status,
    this.rejectionReason,
    this.kyc,
  });

  @override
  List<Object?> get props => [id, userId, status, rejectionReason, kyc];
}

class HostKycStatusEntity extends Equatable {
  final String documentType;
  final String documentNumber;
  final String status;

  const HostKycStatusEntity({
    required this.documentType,
    required this.documentNumber,
    required this.status,
  });

  @override
  List<Object?> get props => [documentType, documentNumber, status];
}
