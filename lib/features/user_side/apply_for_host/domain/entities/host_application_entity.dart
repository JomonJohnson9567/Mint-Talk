import 'package:equatable/equatable.dart';

class HostApplicationEntity extends Equatable {
  final String name;
  final String dob;
  final String bio;

  /// Id returned by POST /host-applications/verification-photo. The selfie
  /// itself is private and never exposed as a URL.
  final String verificationPhotoId;

  /// Optional referral code of the host who referred this applicant.
  final String? referralCode;

  const HostApplicationEntity({
    required this.name,
    required this.dob,
    required this.bio,
    required this.verificationPhotoId,
    this.referralCode,
  });

  @override
  List<Object?> get props => [
    name,
    dob,
    bio,
    verificationPhotoId,
    referralCode,
  ];
}
