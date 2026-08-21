import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/domain/entities/recharge_history_item.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/domain/usecases/get_recharge_history_usecase.dart';
import 'user_recharge_history_state.dart';

@injectable
class UserRechargeHistoryCubit extends Cubit<UserRechargeHistoryState> {
  static const int _pageSize = 8;

  final GetRechargeHistoryUseCase _getRechargeHistoryUseCase;
  final AuthRepository _authRepository;

  UserRechargeHistoryCubit(
    this._getRechargeHistoryUseCase,
    this._authRepository,
  ) : super(const UserRechargeHistoryState());

  Future<void> loadHistory() async {
    if (state.isLoading || state.isRefreshing) return;

    emit(state.copyWith(
      status: UserRechargeHistoryStatus.loading,
      errorMessage: () => null,
    ));
    await _fetchHistory();
  }

  Future<void> refreshHistory() async {
    if (state.isLoading) return;

    emit(state.copyWith(
      status: UserRechargeHistoryStatus.refreshing,
      errorMessage: () => null,
    ));
    await _fetchHistory();
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.history.isEmpty) return;

    emit(state.copyWith(status: UserRechargeHistoryStatus.loadingMore));
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final nextItems = _sliceVisibleHistory(state.history, state.visibleHistory.length);
    emit(state.copyWith(
      status: UserRechargeHistoryStatus.loaded,
      visibleHistory: [...state.visibleHistory, ...nextItems],
      hasMore: state.history.length > state.visibleHistory.length + nextItems.length,
    ));
  }

  Future<void> _fetchHistory() async {
    final userId = await _authRepository.getUserId();
    if (userId == null || userId.isEmpty) {
      emit(state.copyWith(
      status: UserRechargeHistoryStatus.failure,
      errorMessage: () => 'User not logged in',
      ));
      return;
    }

    final result = await _getRechargeHistoryUseCase(userId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: UserRechargeHistoryStatus.failure,
          errorMessage: () => failure.message,
        ));
      },
      (items) {
        final visible = _sliceVisibleHistory(items, 0);
        emit(state.copyWith(
          status: UserRechargeHistoryStatus.loaded,
          history: items,
          visibleHistory: visible,
          hasMore: items.length > visible.length,
          userId: userId,
          errorMessage: () => null,
        ));
      },
    );
  }

  List<RechargeHistoryItem> _sliceVisibleHistory(
    List<RechargeHistoryItem> items,
    int startIndex,
  ) {
    if (startIndex >= items.length) return const [];
    final endIndex = (startIndex + _pageSize).clamp(0, items.length);
    return items.sublist(startIndex, endIndex);
  }
}
