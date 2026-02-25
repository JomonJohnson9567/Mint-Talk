import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:injectable/injectable.dart';

part 'call_screen_state.dart';

@injectable
class CallScreenCubit extends Cubit<CallScreenState> {
  CallScreenCubit() : super(CallOngoing());

  void endCall() {
    emit(CallEnded());
  }

  void startCall() {
    emit(CallOngoing());
  }
}
