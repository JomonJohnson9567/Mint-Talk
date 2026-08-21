import 'package:equatable/equatable.dart';

/// Entity representing a single call log entry.
class HostCallLogEntryEntity extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String duration;
  final bool isVideoCall;
  final bool isBlocked;

  const HostCallLogEntryEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.duration,
    required this.isVideoCall,
    this.isBlocked = false,
  });

  HostCallLogEntryEntity copyWith({bool? isBlocked}) {
    return HostCallLogEntryEntity(
      id: id,
      name: name,
      imageUrl: imageUrl,
      duration: duration,
      isVideoCall: isVideoCall,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  @override
  List<Object?> get props => [id, name, imageUrl, duration, isVideoCall, isBlocked];
}
