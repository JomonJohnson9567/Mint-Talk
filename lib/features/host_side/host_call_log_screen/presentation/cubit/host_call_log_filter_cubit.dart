import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/presentation/widgets/host_call_log_filter_tabs.dart';

/// A minimal Cubit that tracks which call-type filter tab is active
/// (Video Call vs Audio Call) on the Host Call Log screen.
class HostCallLogFilterCubit extends Cubit<HostCallFilterType> {
  HostCallLogFilterCubit() : super(HostCallFilterType.video);

  void changeFilter(HostCallFilterType filter) => emit(filter);
}
