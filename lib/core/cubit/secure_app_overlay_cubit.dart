import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tracks whether the app content should be obscured because the app is
/// backgrounded/inactive (app-switcher snapshot, another app briefly
/// covering it). Registers itself as a [WidgetsBindingObserver] directly —
/// no widget/State needed to host the observer.
class SecureAppOverlayCubit extends Cubit<bool> with WidgetsBindingObserver {
  SecureAppOverlayCubit() : super(false) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final shouldObscure =
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused;
    if (shouldObscure != this.state) {
      emit(shouldObscure);
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
