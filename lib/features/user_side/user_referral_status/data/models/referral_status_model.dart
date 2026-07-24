import 'package:mint_talk/features/user_side/user_referral_status/domain/entities/referral_status_entity.dart';

class ReferralStatusModel extends ReferralStatusEntity {
  const ReferralStatusModel({
    required super.rewardPoints,
    required super.status,
    super.referralCode,
    super.pendingPoints,
    super.totalReferrals,
    super.updatedAt,
    super.shareMessage,
  });

  factory ReferralStatusModel.fromJson(Map<String, dynamic> json) {
    final data = _nestedData(json);

    return ReferralStatusModel(
      rewardPoints: _intFromAny(
        data['rewardPoints'] ??
            data['points'] ??
            data['earnedPoints'] ??
            json['rewardPoints'] ??
            json['points'] ??
            json['earnedPoints'],
      ),
      status: _stringFromAny(
        data['status'] ??
            data['rewardStatus'] ??
            data['badge'] ??
            json['status'] ??
            json['rewardStatus'] ??
            json['badge'],
        fallback: 'pending',
      ),
      referralCode: _stringFromAny(
        data['referralCode'] ??
            data['code'] ??
            json['referralCode'] ??
            json['code'],
      ),
      pendingPoints: _nullableIntFromAny(
        data['pendingPoints'] ??
            data['pendingRewardPoints'] ??
            json['pendingPoints'] ??
            json['pendingRewardPoints'],
      ),
      totalReferrals: _nullableIntFromAny(
        data['totalReferrals'] ??
            data['referralsCount'] ??
            data['referralCount'] ??
            json['totalReferrals'] ??
            json['referralsCount'] ??
            json['referralCount'],
      ),
      updatedAt: _dateFromAny(
        data['updatedAt'] ??
            data['createdAt'] ??
            json['updatedAt'] ??
            json['createdAt'],
      ),
      shareMessage: _stringFromAny(
        data['shareMessage'] ?? json['shareMessage'],
      ),
    );
  }

  static Map<String, dynamic> _nestedData(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return json;
  }

  static int _intFromAny(dynamic value, {int fallback = 0}) {
    return _nullableIntFromAny(value) ?? fallback;
  }

  static int? _nullableIntFromAny(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String _stringFromAny(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static DateTime? _dateFromAny(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
