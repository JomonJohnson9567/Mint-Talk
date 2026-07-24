import 'package:equatable/equatable.dart';

enum HostProfileStatus { initial, loading, loaded, failure }

class HostProfileState extends Equatable {
  final HostProfileStatus status;
  final String? userId;
  final String? fullName;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? role;
  final String? imagePath;
  final int? audioRate;
  final int? videoRate;
  final bool? isAudioAllowed;
  final bool? isVideoAllowed;
  final String? errorMessage;

  const HostProfileState({
    this.status = HostProfileStatus.initial,
    this.userId,
    this.fullName,
    this.phone,
    this.dob,
    this.gender,
    this.role,
    this.imagePath,
    this.audioRate,
    this.videoRate,
    this.isAudioAllowed,
    this.isVideoAllowed,
    this.errorMessage,
  });

  bool get isLoading =>
      status == HostProfileStatus.initial ||
      status == HostProfileStatus.loading;

  String get displayName {
    final value = fullName?.trim() ?? '';
    return value.isEmpty ? 'Host' : value;
  }

  String get displayPhone {
    final value = phone?.trim() ?? '';
    return value.isEmpty ? 'Phone unavailable' : value;
  }

  String get displayUserId {
    final value = userId?.trim() ?? '';
    return value.isEmpty ? 'ID unavailable' : value;
  }

  String get displayDob {
    final value = dob?.trim() ?? '';
    return value.isEmpty ? 'Not provided' : value;
  }

  String get displayGender {
    final value = gender?.trim() ?? '';
    if (value.isEmpty) return 'Not provided';
    return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
  }

  String get displayRole {
    final value = role?.trim() ?? '';
    if (value.isEmpty) return 'Host account';
    return value == 'staff' ? 'Verified host' : value;
  }

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2);
    return parts.map((part) => part[0].toUpperCase()).join();
  }

  HostProfileState copyWith({
    HostProfileStatus? status,
    String? userId,
    String? fullName,
    String? phone,
    String? dob,
    String? gender,
    String? role,
    String? imagePath,
    int? audioRate,
    int? videoRate,
    bool? isAudioAllowed,
    bool? isVideoAllowed,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HostProfileState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      imagePath: imagePath ?? this.imagePath,
      audioRate: audioRate ?? this.audioRate,
      videoRate: videoRate ?? this.videoRate,
      isAudioAllowed: isAudioAllowed ?? this.isAudioAllowed,
      isVideoAllowed: isVideoAllowed ?? this.isVideoAllowed,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userId,
    fullName,
    phone,
    dob,
    gender,
    role,
    imagePath,
    audioRate,
    videoRate,
    isAudioAllowed,
    isVideoAllowed,
    errorMessage,
  ];
}
