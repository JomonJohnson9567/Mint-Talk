import 'package:equatable/equatable.dart';

class ReferralStatusEntity extends Equatable {
  final int rewardPoints;
  final String status;
  final String? referralCode;
  final int? pendingPoints;
  final int? totalReferrals;
  final DateTime? updatedAt;
  final String? shareMessage;

  const ReferralStatusEntity({
    required this.rewardPoints,
    required this.status,
    this.referralCode,
    this.pendingPoints,
    this.totalReferrals,
    this.updatedAt,
    this.shareMessage,
  });

  bool get isRewarded => status.toLowerCase() == 'rewarded';

  bool get isPending => status.toLowerCase() == 'pending';

  bool get hasReferralCode =>
      referralCode != null && referralCode!.trim().isNotEmpty;

  ReferralStatusEntity copyWith({
    int? rewardPoints,
    String? status,
    String? referralCode,
    int? pendingPoints,
    int? totalReferrals,
    DateTime? updatedAt,
    String? shareMessage,
  }) {
    return ReferralStatusEntity(
      rewardPoints: rewardPoints ?? this.rewardPoints,
      status: status ?? this.status,
      referralCode: referralCode ?? this.referralCode,
      pendingPoints: pendingPoints ?? this.pendingPoints,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      updatedAt: updatedAt ?? this.updatedAt,
      shareMessage: shareMessage ?? this.shareMessage,
    );
  }

  @override
  List<Object?> get props => [
    rewardPoints,
    status,
    referralCode,
    pendingPoints,
    totalReferrals,
    updatedAt,
    shareMessage,
  ];
}
