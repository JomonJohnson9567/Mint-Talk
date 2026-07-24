import 'package:equatable/equatable.dart';

/// Model representing a single call log entry.
class HostCallLogEntryModel extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String duration;
  final bool isVideoCall;
  final bool isBlocked;

  const HostCallLogEntryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.duration,
    required this.isVideoCall,
    this.isBlocked = false,
  });

  HostCallLogEntryModel copyWith({bool? isBlocked}) {
    return HostCallLogEntryModel(
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
