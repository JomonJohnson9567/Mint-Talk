import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/features/user_side/call_log/domain/usecases/get_host_call_logs_usecase.dart';
import 'package:mint_talk/features/user_side/call_log/domain/usecases/get_user_call_logs_usecase.dart';
import 'package:mint_talk/features/shared/block_users/domain/usecases/block_user_usecase.dart';
import 'package:mint_talk/features/shared/block_users/domain/usecases/unblock_user_usecase.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/domain/models/host_call_log_entry_model.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/presentation/cubit/host_call_log_state.dart';

@injectable
class HostCallLogCubit extends Cubit<HostCallLogState> {
  final GetHostCallLogsUseCase getHostCallLogsUseCase;
  final BlockUserUseCase blockUserUseCase;
  final UnblockUserUseCase unblockUserUseCase;

  HostCallLogCubit({
    required this.getHostCallLogsUseCase,
    required this.blockUserUseCase,
    required this.unblockUserUseCase,
  }) : super(const HostCallLogInitial()) {
    loadCallLogs();
  }

  Future<void> loadCallLogs() async {
    final result = await getHostCallLogsUseCase(const GetCallLogsParams());

    result.fold(
      (failure) => emit(const HostCallLogLoaded(entries: [])),
      (entities) {
        final entries = entities.map((entity) {
          final callerName = entity.caller?.fullName.isNotEmpty == true
              ? entity.caller!.fullName
              : 'User';
          final avatarUrl = entity.caller?.avatarUrl.isNotEmpty == true
              ? entity.caller!.avatarUrl
              : AppAssets.femaleIcon;
          final durationText = entity.duration > 0
              ? '${entity.duration ~/ 60}.${(entity.duration % 60).toString().padLeft(2, '0')} m'
              : '0 m';

          return HostCallLogEntryModel(
            id: entity.caller?.id ?? entity.id,
            name: callerName,
            imageUrl: avatarUrl,
            duration: durationText,
            isVideoCall: entity.callType == 'video',
            isBlocked: false,
          );
        }).toList();
        emit(HostCallLogLoaded(entries: entries));
      },
    );
  }

  /// Toggles the blocked flag for the entry with [userId].
  Future<void> blockUser(String userId) async {
    final current = state;
    if (current is! HostCallLogLoaded) return;

    final targetEntry = current.entries.firstWhere(
      (e) => e.id == userId,
      orElse: () => current.entries.first,
    );

    final currentlyBlocked = targetEntry.isBlocked;

    if (currentlyBlocked) {
      await unblockUserUseCase(UnblockUserParams(userId: userId));
    } else {
      await blockUserUseCase(BlockUserParams(userId: userId));
    }

    final updated = current.entries.map((e) {
      return e.id == userId ? e.copyWith(isBlocked: !e.isBlocked) : e;
    }).toList();

    emit(HostCallLogLoaded(entries: updated));
  }
}

