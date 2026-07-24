import 'package:equatable/equatable.dart';

import 'package:mint_talk/features/user_side/user_recharge_history/domain/entities/recharge_history_item.dart';

enum UserRechargeHistoryStatus {
  initial,
  loading,
  loaded,
  refreshing,
  loadingMore,
  failure,
}

class UserRechargeHistoryState extends Equatable {
  final UserRechargeHistoryStatus status;
  final List<RechargeHistoryItem> history;
  final List<RechargeHistoryItem> visibleHistory;
  final String? errorMessage;
  final bool hasMore;
  final String? userId;

  const UserRechargeHistoryState({
    this.status = UserRechargeHistoryStatus.initial,
    this.history = const [],
    this.visibleHistory = const [],
    this.errorMessage,
    this.hasMore = false,
    this.userId,
  });

  bool get isLoading => status == UserRechargeHistoryStatus.loading;

  bool get isRefreshing => status == UserRechargeHistoryStatus.refreshing;

  bool get isLoadingMore => status == UserRechargeHistoryStatus.loadingMore;

  UserRechargeHistoryState copyWith({
    UserRechargeHistoryStatus? status,
    List<RechargeHistoryItem>? history,
    List<RechargeHistoryItem>? visibleHistory,
    String? Function()? errorMessage,
    bool? hasMore,
    String? userId,
  }) {
    return UserRechargeHistoryState(
      status: status ?? this.status,
      history: history ?? this.history,
      visibleHistory: visibleHistory ?? this.visibleHistory,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        history,
        visibleHistory,
        errorMessage,
        hasMore,
        userId,
      ];
}
