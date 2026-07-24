part of 'profile_info_cubit.dart';

class ProfileInfoState extends Equatable {
  final bool isLoading;
  final String? fullName;
  final String? phone;
  final String? referralCode;
  final String? imagePath;

  const ProfileInfoState({
    this.isLoading = false,
    this.fullName,
    this.phone,
    this.referralCode,
    this.imagePath,
  });

  ProfileInfoState copyWith({
    bool? isLoading,
    String? fullName,
    String? phone,
    String? referralCode,
    String? imagePath,
  }) {
    return ProfileInfoState(
      isLoading: isLoading ?? this.isLoading,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      referralCode: referralCode ?? this.referralCode,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    fullName,
    phone,
    referralCode,
    imagePath,
  ];
}
