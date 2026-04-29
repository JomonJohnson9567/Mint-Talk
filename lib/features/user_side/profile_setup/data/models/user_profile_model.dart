import 'package:mint_talk/features/user_side/profile_setup/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.fullName,
    required super.dob,
    required super.gender,
    required super.referralCode,
    required super.termsAcceptedAt,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'fullName': fullName.value,
      'dob': dob.date.toIso8601String().split('T')[0],
      'gender': gender.value.name,
      'termsAcceptedAt': termsAcceptedAt,
    };

    if (referralCode.value != null && referralCode.value!.isNotEmpty) {
      data['referralCode'] = referralCode.value;
    }

    return data;
  }

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      fullName: entity.fullName,
      dob: entity.dob,
      gender: entity.gender,
      referralCode: entity.referralCode,
      termsAcceptedAt: entity.termsAcceptedAt,
    );
  }
}
