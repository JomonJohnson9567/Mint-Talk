import 'package:flutter_bloc/flutter_bloc.dart';

/// Generic "is this pressed right now" flag for widgets that want a
/// scale-down-on-press visual affordance without their own local State.
/// Instantiate one per pressable widget instance.
class PressedStateCubit extends Cubit<bool> {
  PressedStateCubit() : super(false);

  void press() => emit(true);

  void release() => emit(false);
}
