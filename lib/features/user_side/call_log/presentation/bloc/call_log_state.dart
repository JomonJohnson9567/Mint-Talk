import 'package:equatable/equatable.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/features/user_side/call_log/domain/entities/call_log_entity.dart';

enum CallLogStatus { initial, loading, loaded, failure }

/// The All / Audio / Video pills.
enum CallLogTypeFilter { all, audio, video }

/// The status filter sheet behind the app bar's tune icon.
enum CallLogStatusFilter { all, completed, missed }

class CallLogEntry extends Equatable {
  final String? callId;
  final String hostId;
  final String name;
  final String imageUrl;
  final DateTime? createdAt;
  final int durationSeconds;
  final bool isVideoCall;
  final bool isMissed;

  const CallLogEntry({
    this.callId,
    required this.hostId,
    required this.name,
    required this.imageUrl,
    required this.createdAt,
    required this.durationSeconds,
    required this.isVideoCall,
    required this.isMissed,
  });

  factory CallLogEntry.fromCallLogEntity(CallLogEntity entity) {
    final name = entity.host?.fullName.isNotEmpty == true
        ? entity.host!.fullName
        : (entity.caller?.fullName.isNotEmpty == true
              ? entity.caller!.fullName
              : 'Call Participant');
    final imageUrl = entity.host?.avatarUrl.isNotEmpty == true
        ? entity.host!.avatarUrl
        : (entity.caller?.avatarUrl ?? '');

    return CallLogEntry(
      callId: entity.id,
      hostId: entity.host?.id ?? '',
      name: name,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : AppAssets.femaleIcon,
      createdAt: entity.createdAt?.toLocal(),
      durationSeconds: entity.duration,
      isVideoCall: entity.callType == 'video',
      isMissed: entity.status == 'missed' || entity.status == 'rejected',
    );
  }

  @override
  List<Object?> get props => [
    callId,
    hostId,
    name,
    imageUrl,
    createdAt,
    durationSeconds,
    isVideoCall,
    isMissed,
  ];
}

class CallLogState extends Equatable {
  final CallLogStatus status;
  final List<CallLogEntry> callLogs;
  final CallLogTypeFilter typeFilter;
  final CallLogStatusFilter statusFilter;
  final String query;
  final String? errorMessage;

  const CallLogState({
    this.status = CallLogStatus.initial,
    this.callLogs = const [],
    this.typeFilter = CallLogTypeFilter.all,
    this.statusFilter = CallLogStatusFilter.all,
    this.query = '',
    this.errorMessage,
  });

  bool get isLoading =>
      status == CallLogStatus.initial || status == CallLogStatus.loading;

  bool get hasActiveFilters =>
      typeFilter != CallLogTypeFilter.all ||
      statusFilter != CallLogStatusFilter.all ||
      query.trim().isNotEmpty;

  /// [callLogs] narrowed by the pills, the status sheet and the search box —
  /// all applied locally so switching filters never refetches.
  List<CallLogEntry> get visibleLogs {
    final needle = query.trim().toLowerCase();
    return callLogs.where((log) {
      final typeMatches = switch (typeFilter) {
        CallLogTypeFilter.all => true,
        CallLogTypeFilter.audio => !log.isVideoCall,
        CallLogTypeFilter.video => log.isVideoCall,
      };
      final statusMatches = switch (statusFilter) {
        CallLogStatusFilter.all => true,
        CallLogStatusFilter.completed => !log.isMissed,
        CallLogStatusFilter.missed => log.isMissed,
      };
      return typeMatches &&
          statusMatches &&
          (needle.isEmpty || log.name.toLowerCase().contains(needle));
    }).toList();
  }

  CallLogState copyWith({
    CallLogStatus? status,
    List<CallLogEntry>? callLogs,
    CallLogTypeFilter? typeFilter,
    CallLogStatusFilter? statusFilter,
    String? query,
    String? Function()? errorMessage,
  }) {
    return CallLogState(
      status: status ?? this.status,
      callLogs: callLogs ?? this.callLogs,
      typeFilter: typeFilter ?? this.typeFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      query: query ?? this.query,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    callLogs,
    typeFilter,
    statusFilter,
    query,
    errorMessage,
  ];
}
