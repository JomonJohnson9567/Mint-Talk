import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/shared/system_config/domain/usecases/get_system_config_usecase.dart';
import 'system_config_state.dart';

/// Single, app-wide instance (provided once at the app root, same as
/// `WalletCubit`/`NotificationsCubit`) so every rate label reads the rates
/// and their units (`billingUnit` / `hostBillingUnit`) from one shared
/// source instead of each screen fetching independently.
///
/// Fetched on app load, on pull-to-refresh, and again on every app resume
/// so admin changes to the rates or units (second ↔ minute) show up without
/// a restart.
@injectable
class SystemConfigCubit extends Cubit<SystemConfigState>
    with WidgetsBindingObserver {
  final GetSystemConfigUseCase _getSystemConfigUseCase;

  SystemConfigCubit(this._getSystemConfigUseCase)
    : super(const SystemConfigState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) fetchConfig();
  }

  Future<void> fetchConfig() async {
    if (state.status == SystemConfigStatus.loading) return;

    emit(state.copyWith(status: SystemConfigStatus.loading));
    final result = await _getSystemConfigUseCase(NoParams());
    if (isClosed) return;

    result.fold(
      // Keep the last-known (or default) units on failure — rate labels
      // stay correct rather than falling back to a raw error state.
      (failure) => emit(state.copyWith(status: SystemConfigStatus.failure)),
      (config) => emit(
        state.copyWith(
          status: SystemConfigStatus.loaded,
          billingUnit: config.billingUnit,
          hostBillingUnit: config.hostBillingUnit,
          defaultAudioRate: config.defaultAudioRate,
          defaultVideoRate: config.defaultVideoRate,
          hostAudioEarningRateInr: config.hostAudioEarningRateInr,
          hostVideoEarningRateInr: config.hostVideoEarningRateInr,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
