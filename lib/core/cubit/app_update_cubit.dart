import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/services/app_update/i_app_update_service.dart';

enum AppUpdateStatus {
  /// Nothing to show.
  idle,

  /// A newer Play Store build exists — prompt "Update / Later".
  available,

  /// The user accepted; Play is downloading in the background.
  downloading,

  /// Downloaded — prompt "Restart now" to install.
  readyToInstall,
}

class AppUpdateState extends Equatable {
  final AppUpdateStatus status;
  final bool flexibleAllowed;
  final int? availableVersionCode;

  /// "Later" was tapped (or Play's dialog was declined) — don't prompt
  /// again until the next cold start.
  final bool dismissed;

  const AppUpdateState({
    this.status = AppUpdateStatus.idle,
    this.flexibleAllowed = false,
    this.availableVersionCode,
    this.dismissed = false,
  });

  AppUpdateState copyWith({
    AppUpdateStatus? status,
    bool? flexibleAllowed,
    int? availableVersionCode,
    bool? dismissed,
  }) {
    return AppUpdateState(
      status: status ?? this.status,
      flexibleAllowed: flexibleAllowed ?? this.flexibleAllowed,
      availableVersionCode: availableVersionCode ?? this.availableVersionCode,
      dismissed: dismissed ?? this.dismissed,
    );
  }

  @override
  List<Object?> get props => [
    status,
    flexibleAllowed,
    availableVersionCode,
    dismissed,
  ];
}

/// Detects a newer Play Store build and drives the optional (flexible)
/// update: prompt → background download → "restart to install". The prompts
/// themselves are shown by the app-wide listener in `app.dart`.
///
/// Checks once after the splash screen (see `SplashScreen`) and again when
/// the app returns to the foreground, at most every [_resumeCheckInterval].
@injectable
class AppUpdateCubit extends Cubit<AppUpdateState> with WidgetsBindingObserver {
  static const _resumeCheckInterval = Duration(minutes: 30);

  final IAppUpdateService _service;
  StreamSubscription<void>? _downloadSub;
  DateTime? _lastCheckAt;
  bool _checking = false;

  AppUpdateCubit(this._service) : super(const AppUpdateState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> checkForUpdate() async {
    if (_checking || state.status == AppUpdateStatus.downloading) return;
    _checking = true;
    _lastCheckAt = DateTime.now();
    try {
      final result = await _service.checkForUpdate();
      if (isClosed) return;
      switch (result.availability) {
        case AppUpdateAvailability.downloaded:
          emit(state.copyWith(status: AppUpdateStatus.readyToInstall));
        case AppUpdateAvailability.available:
          if (state.dismissed) return;
          emit(
            state.copyWith(
              status: AppUpdateStatus.available,
              flexibleAllowed: result.flexibleAllowed,
              availableVersionCode: result.availableVersionCode,
            ),
          );
        case AppUpdateAvailability.none:
          if (state.status == AppUpdateStatus.available) {
            emit(state.copyWith(status: AppUpdateStatus.idle));
          }
      }
    } finally {
      _checking = false;
    }
  }

  /// "Update" tapped on the prompt.
  Future<void> startUpdate() async {
    if (state.status != AppUpdateStatus.available) return;

    if (!state.flexibleAllowed) {
      // Play won't run an in-app update right now — send the user to the
      // store listing instead.
      emit(state.copyWith(status: AppUpdateStatus.idle, dismissed: true));
      await _service.openStoreListing();
      return;
    }

    await _downloadSub?.cancel();
    _downloadSub = _service.downloadStarted.listen((_) {
      if (!isClosed && state.status == AppUpdateStatus.available) {
        emit(state.copyWith(status: AppUpdateStatus.downloading));
      }
    });

    final downloaded = await _service.startFlexibleUpdate();
    await _downloadSub?.cancel();
    _downloadSub = null;
    if (isClosed) return;

    emit(
      downloaded
          ? state.copyWith(status: AppUpdateStatus.readyToInstall)
          // Declined Play's dialog, or the download failed.
          : state.copyWith(status: AppUpdateStatus.idle, dismissed: true),
    );
  }

  /// "Later" tapped (or the prompt was dismissed).
  void dismiss() {
    if (state.status != AppUpdateStatus.available) return;
    emit(state.copyWith(status: AppUpdateStatus.idle, dismissed: true));
  }

  /// "Restart now" tapped — Play installs and relaunches the app.
  Future<void> installNow() async {
    if (state.status != AppUpdateStatus.readyToInstall) return;
    await _service.completeFlexibleUpdate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // Before the first (post-splash) check, leave the timing to the splash.
    final last = _lastCheckAt;
    if (last == null) return;
    if (DateTime.now().difference(last) < _resumeCheckInterval) return;
    checkForUpdate();
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _downloadSub?.cancel();
    return super.close();
  }
}
