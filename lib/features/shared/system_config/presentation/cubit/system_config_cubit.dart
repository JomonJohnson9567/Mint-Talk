import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/shared/system_config/domain/usecases/get_system_config_usecase.dart';
import 'system_config_state.dart';

/// Single, app-wide instance (provided once at the app root, same as
/// `WalletCubit`/`NotificationsCubit`) fetched once on app load so every
/// rate label reads `billingUnit` from one shared source instead of each
/// screen fetching independently.
@injectable
class SystemConfigCubit extends Cubit<SystemConfigState> {
  final GetSystemConfigUseCase _getSystemConfigUseCase;

  SystemConfigCubit(this._getSystemConfigUseCase) : super(const SystemConfigState());

  Future<void> fetchConfig() async {
    if (state.status == SystemConfigStatus.loading) return;

    emit(state.copyWith(status: SystemConfigStatus.loading));
    final result = await _getSystemConfigUseCase(NoParams());

    result.fold(
      // Keep the last-known (or default) billingUnit on failure — rate
      // labels stay correct rather than falling back to a raw error state.
      (failure) => emit(state.copyWith(status: SystemConfigStatus.failure)),
      (config) => emit(
        state.copyWith(
          status: SystemConfigStatus.loaded,
          billingUnit: config.billingUnit,
        ),
      ),
    );
  }
}
