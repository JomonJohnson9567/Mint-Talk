import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/services/device_security/i_device_security_service.dart';

/// `true` while the app must be blocked because Developer options are on.
///
/// Checked once before `runApp` (see `main.dart`) and again on every resume,
/// which is how toggling Developer options in Settings is picked up — it
/// can't change without leaving the app.
@lazySingleton
class DeveloperModeCubit extends Cubit<bool> with WidgetsBindingObserver {
  final IDeviceSecurityService _deviceSecurity;

  DeveloperModeCubit(this._deviceSecurity) : super(false) {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> check() async {
    final blocked = await _deviceSecurity.isDeveloperModeEnabled();
    if (!isClosed) emit(blocked);
  }

  Future<void> openDeveloperSettings() =>
      _deviceSecurity.openDeveloperSettings();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) check();
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
