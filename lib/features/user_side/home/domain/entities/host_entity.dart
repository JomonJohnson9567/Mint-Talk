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
  });

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
      ];
}
