import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/widgets/call_log_item.dart';

part 'call_log_state.dart';

class CallLogCubit extends Cubit<CallLogState> {
  CallLogCubit() : super(CallLogInitial()) {
    loadCallLogs();
  }

  void loadCallLogs() {
    // Simulating data fetching
    final logs = [
      CallLogEntry(
        name: 'Jane Cooper',
        imageUrl: AppAssets.femaleIcon,
        time: 'Today, 09:30 AM',
        type: CallType.outgoing,
        isVideoCall: true,
        duration: '12m 30s',
      ),
      CallLogEntry(
        name: 'Savannah Nguyen',
        imageUrl: AppAssets.femaleIcon,
        time: 'Yesterday, 08:45 PM',
        type: CallType.missed,
        isVideoCall: false,
      ),
      CallLogEntry(
        name: 'Esther Howard',
        imageUrl: AppAssets.femaleIcon,
        time: 'Yesterday, 06:12 PM',
        type: CallType.outgoing,
        isVideoCall: true,
        duration: '5m 45s',
      ),
      CallLogEntry(
        name: 'Jenny Wilson',
        imageUrl: AppAssets.femaleIcon,
        time: 'Oct 24, 10:00 AM',
        type: CallType.outgoing,
        isVideoCall: false,
        duration: '23m 10s',
      ),
      CallLogEntry(
        name: 'Courtney Henry',
        imageUrl: AppAssets.femaleIcon,
        time: 'Oct 23, 09:15 AM',
        type: CallType.missed,
        isVideoCall: true,
      ),
      CallLogEntry(
        name: 'Esther Howard',
        imageUrl: AppAssets.femaleIcon,
        time: 'Yesterday, 06:12 PM',
        type: CallType.missed,
        isVideoCall: true,
        duration: '8m 20s',
      ),
      CallLogEntry(
        name: 'Esther Howard',
        imageUrl: AppAssets.femaleIcon,
        time: 'Yesterday, 06:12 PM',
        type: CallType.outgoing,
        isVideoCall: true,
        duration: '10m 00s',
      ),
      CallLogEntry(
        name: 'Esther Howard',
        imageUrl: AppAssets.femaleIcon,
        time: 'Yesterday, 06:12 PM',
        type: CallType.outgoing,
        isVideoCall: true,
        duration: '2m 15s',
      ),
    ];
    emit(CallLogLoaded(logs));
  }
}
