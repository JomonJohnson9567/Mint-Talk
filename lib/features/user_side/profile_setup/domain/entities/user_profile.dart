import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/value_objects/full_name.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/value_objects/dob.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/value_objects/gender_value.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/value_objects/referral_code_value.dart';

class UserProfile extends Equatable {
  final FullName fullName;
  final DateOfBirth dob;
  final GenderValue gender;
  final ReferralCodeValue referralCode;
  final String termsAcceptedAt;

  const UserProfile({
    required this.fullName,
    required this.dob,
    required this.gender,
    required this.referralCode,
    required this.termsAcceptedAt,
  });

  @override
  List<Object?> get props => [
        fullName,
        dob,
        gender,
        referralCode,
        termsAcceptedAt,
      ];
}
