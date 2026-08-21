import 'package:equatable/equatable.dart';

/// Domain entity representing a user.
/// Has NO dependency on any data or framework layer.
class UserEntity extends Equatable {
  final String id;
  final String phone;
  final String role;
  final bool profileCompleted;
  final String? fullName;
  final String? gender;
  final String? dob;
  final String? referralCode;
  final int? audioRate;
  final int? videoRate;
  final bool? isAudioAllowed;
  final bool? isVideoAllowed;
  final String? avatarUrl;
  final String? termsAcceptedAt;

  const UserEntity({
    required this.id,
    required this.phone,
    required this.role,
    required this.profileCompleted,
    this.fullName,
    this.gender,
    this.dob,
    this.referralCode,
    this.avatarUrl,
    this.audioRate,
    this.videoRate,
    this.isAudioAllowed,
    this.isVideoAllowed,
    this.termsAcceptedAt,
  });

  @override
  List<Object?> get props => [
    id,
    phone,
    role,
    profileCompleted,
    fullName,
    gender,
    dob,
    referralCode,
    avatarUrl,
    audioRate,
    videoRate,
    isAudioAllowed,
    isVideoAllowed,
    termsAcceptedAt,
  ];
}
