import 'package:equatable/equatable.dart';

enum ApplyForHostStatus { initial, loading, submitting, success, failure }

/// Result of the live `/user/referral-verify` check, mirrored from
/// `ReferralCubit` so this cubit stays decoupled from it.
enum ReferralCheck { idle, checking, valid, invalid }

class ApplyForHostState extends Equatable {
  final String name;
  final String dob;
  final String bio;
  /// Local file shown as the in-form preview only.
  final String selfiePath;

  /// Private id from the verification-photo upload; empty until uploaded.
  final String verificationPhotoId;

  /// Optional — empty means no referral code entered.
  final String referralCode;
  final ReferralCheck referralStatus;

  final bool isUploadingSelfie;

  final ApplyForHostStatus status;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  const ApplyForHostState({
    this.name = '',
    this.dob = '',
    this.bio = '',
    this.selfiePath = '',
    this.verificationPhotoId = '',
    this.referralCode = '',
    this.referralStatus = ReferralCheck.idle,
    this.isUploadingSelfie = false,
    this.status = ApplyForHostStatus.initial,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  bool get isFormValid =>
      name.trim().length >= 3 &&
      name.trim().length <= 50 &&
      dob.isNotEmpty &&
      bio.trim().length >= 10 &&
      selfiePath.isNotEmpty &&
      verificationPhotoId.isNotEmpty &&
      !isUploadingSelfie &&
      (referralCode.isEmpty || referralStatus == ReferralCheck.valid) &&
      fieldErrors.values.every((error) => error.isEmpty);

  ApplyForHostState copyWith({
    String? name,
    String? dob,
    String? bio,
    String? selfiePath,
    String? verificationPhotoId,
    String? referralCode,
    ReferralCheck? referralStatus,
    bool? isUploadingSelfie,
    ApplyForHostStatus? status,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return ApplyForHostState(
      name: name ?? this.name,
      dob: dob ?? this.dob,
      bio: bio ?? this.bio,
      selfiePath: selfiePath ?? this.selfiePath,
      verificationPhotoId: verificationPhotoId ?? this.verificationPhotoId,
      referralCode: referralCode ?? this.referralCode,
      referralStatus: referralStatus ?? this.referralStatus,
      isUploadingSelfie: isUploadingSelfie ?? this.isUploadingSelfie,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [
    name,
    dob,
    bio,
    selfiePath,
    verificationPhotoId,
    referralCode,
    referralStatus,
    isUploadingSelfie,
    status,
    errorMessage,
    fieldErrors,
  ];
}
