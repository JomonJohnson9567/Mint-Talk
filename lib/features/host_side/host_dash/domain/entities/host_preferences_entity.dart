import 'package:equatable/equatable.dart';

class HostPreferencesEntity extends Equatable {
  final int audioRate;
  final int videoRate;
  final bool isAudioAllowed;
  final bool isVideoAllowed;

  const HostPreferencesEntity({
    required this.audioRate,
    required this.videoRate,
    required this.isAudioAllowed,
    required this.isVideoAllowed,
  });

  @override
  List<Object?> get props => [
    audioRate,
    videoRate,
    isAudioAllowed,
    isVideoAllowed,
  ];
}
