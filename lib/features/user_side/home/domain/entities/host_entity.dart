import 'package:equatable/equatable.dart';
import 'host_presence_entity.dart';

class HostEntity extends Equatable {
  final String id;
  final String fullName;
  final String phone;
  final String avatarUrl;
  final String selfieUrl;
  final String dob;
  final String gender;
  final num audioRate;
  final num videoRate;
  final bool isAudioAllowed;
  final bool isVideoAllowed;
  final HostPresenceEntity? presence;
  final bool isFavorite;

  const HostEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.avatarUrl,
    required this.selfieUrl,
    required this.dob,
    required this.gender,
    required this.audioRate,
    required this.videoRate,
    required this.isAudioAllowed,
    required this.isVideoAllowed,
    this.presence,
    this.isFavorite = false,
  });

  HostEntity copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? selfieUrl,
    String? dob,
    String? gender,
    num? audioRate,
    num? videoRate,
    bool? isAudioAllowed,
    bool? isVideoAllowed,
    HostPresenceEntity? presence,
    bool? isFavorite,
  }) {
    return HostEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      audioRate: audioRate ?? this.audioRate,
      videoRate: videoRate ?? this.videoRate,
      isAudioAllowed: isAudioAllowed ?? this.isAudioAllowed,
      isVideoAllowed: isVideoAllowed ?? this.isVideoAllowed,
      presence: presence ?? this.presence,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        phone,
        avatarUrl,
        selfieUrl,
        dob,
        gender,
        audioRate,
        videoRate,
        isAudioAllowed,
        isVideoAllowed,
        presence,
        isFavorite,
      ];
}
