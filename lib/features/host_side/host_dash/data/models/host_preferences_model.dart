import '../../domain/entities/host_preferences_entity.dart';

class HostPreferencesModel extends HostPreferencesEntity {
  const HostPreferencesModel({
    required super.audioRate,
    required super.videoRate,
    required super.isAudioAllowed,
    required super.isVideoAllowed,
  });

  factory HostPreferencesModel.fromEntity(HostPreferencesEntity entity) {
    return HostPreferencesModel(
      audioRate: entity.audioRate,
      videoRate: entity.videoRate,
      isAudioAllowed: entity.isAudioAllowed,
      isVideoAllowed: entity.isVideoAllowed,
    );
  }

  factory HostPreferencesModel.fromJson(Map<String, dynamic> json) {
    return HostPreferencesModel(
      audioRate: (json['audioRate'] as num?)?.toInt() ?? 0,
      videoRate: (json['videoRate'] as num?)?.toInt() ?? 0,
      isAudioAllowed: json['isAudioAllowed'] == true,
      isVideoAllowed: json['isVideoAllowed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioRate': audioRate,
      'videoRate': videoRate,
      'isAudioAllowed': isAudioAllowed,
      'isVideoAllowed': isVideoAllowed,
    };
  }
}
