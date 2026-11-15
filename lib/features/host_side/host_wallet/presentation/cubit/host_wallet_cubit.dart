import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_wallet_entities.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/withdrawal_amount_validator.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/usecases/get_host_wallet_overview_usecase.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/usecases/get_unconfirmed_withdrawal_usecase.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/usecases/request_withdrawal_usecase.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_state.dart';
import 'package:mint_talk/features/shared/notifications/domain/entities/notification_entity.dart';
import 'package:mint_talk/features/shared/notifications/domain/usecases/watch_new_notifications_usecase.dart';

/// Wallet screen state. Lives exactly as long as the wallet route, so
/// "while the screen is visible" = while this cubit is open and the app is
/// in the foreground.
///
/// Balances, totals and statuses always come from the latest
/// `/withdrawals/my-requests` response — nothing is deducted or restored
/// locally; every action is followed by a refresh instead.
@injectable
class HostWalletCubit extends Cubit<HostWalletState>
    with WidgetsBindingObserver {
  final GetHostWalletOverviewUseCase _getOverview;
  final RequestWithdrawalUseCase _requestWithdrawal;
  final GetUnconfirmedWithdrawalUseCase _getUnconfirmed;
  final WatchNewNotificationsUseCase _watchNotifications;

  /// Refresh cadence while a withdrawal is `processing` (spec: 20–30 s).
  @visibleForTesting
  static Duration processingPollInterval = const Duration(seconds: 25);

  Timer? _pollTimer;
  StreamSubscription<NotificationEntity>? _notificationSub;
  Future<void>? _loadInFlight;
  bool _appInForeground = true;

  HostWalletCubit(
    this._getOverview,
    this._requestWithdrawal,
    this._getUnconfirmed,
    this._watchNotifications,
  ) : super(const HostWalletState()) {
    WidgetsBinding.instance.addObserver(this);
    _notificationSub = _watchNotifications().listen(_onNotification);
  }

  /// First load on opening the wallet. A request left unconfirmed by a
  /// timeout or an app restart is resumed with its original key and body.
  Future<void> initialize() async {
    await loadWallet();
    if (!isClosed && state.unconfirmedRequest != null) {
      await retryUnconfirmedWithdrawal();
    }
  }

  /// Refreshes balance, summary, accounts, eligibility and history. Calls
  /// made while one is running share it.
  Future<void> loadWallet() => _loadInFlight ??= _load().whenComplete(() {
    _loadInFlight = null;
  });

  Future<void> _load() async {
    if (state.overview == null) {
      emit(state.copyWith(status: HostWalletStatus.loading, errorMessage: ''));
    }

    final result = await _getOverview(NoParams());
    final unconfirmed = await _getUnconfirmed();
    if (isClosed) return;

    result.fold(
      (failure) {
        // Keep showing the last good data on a failed background refresh.
        if (state.overview != null) return;
        emit(
          state.copyWith(
            status: HostWalletStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (overview) {
        final methods = overview.selectableAccounts
            .map((account) => account.method)
            .toSet();
        final keepSelection = methods.contains(state.selectedPayoutMethod);
        emit(
          state.copyWith(
            status: HostWalletStatus.loaded,
            overview: overview,
            errorMessage: '',
            selectedPayoutMethod: keepSelection
                ? state.selectedPayoutMethod
                : (methods.isEmpty ? null : methods.first),
            clearSelectedPayoutMethod: !keepSelection && methods.isEmpty,
            unconfirmedRequest: unconfirmed,
            clearUnconfirmedRequest: unconfirmed == null,
          ),
        );
      },
    );
    _syncPolling();
  }

  void updateWithdrawalAmount(String value) {
    emit(state.copyWith(withdrawalAmount: value, requestMessage: ''));
  }

  /// Picks a verified, active account's method; others are ignored.
  void selectPayoutMethod(String method) {
    final selectable = state.payoutAccounts.any(
      (account) => account.isSelectable && account.method == method,
    );
    if (!selectable) return;
    emit(state.copyWith(selectedPayoutMethod: method, requestMessage: ''));
  }

  /// Resets the sheet's transient fields before it opens.
  void prepareWithdrawalSheet() {
    emit(
      state.copyWith(
        withdrawalAmount: '',
        requestMessage: '',
        requestStatus: HostWalletRequestStatus.idle,
      ),
    );
  }

  Future<bool> submitWithdrawal() async {
    if (state.isSubmitting) return false;

    final block = state.withdrawalBlock;
    if (block != null) {
      emit(state.copyWith(requestMessage: withdrawalBlockMessage(state)));
      return false;
    }

    final amountError = state.amountError;
    if (amountError != null) {
      emit(state.copyWith(requestMessage: amountErrorMessage(state)));
      return false;
    }

    final method = state.selectedPayoutMethod;
    if (method == null) {
      emit(state.copyWith(requestMessage: AppTexts.selectPayoutAccount));
      return false;
    }

    return _send(
      HostWithdrawalRequestParams(
        amount: WithdrawalAmountValidator.parse(state.withdrawalAmount)!,
        payoutMethod: method,
      ),
    );
  }

  /// Re-sends the unconfirmed request with exactly its original body, so
  /// the repository reuses its `Idempotency-Key`.
  Future<bool> retryUnconfirmedWithdrawal() async {
    final pending = state.unconfirmedRequest;
    if (pending == null || state.isSubmitting) return false;
    return _send(
      HostWithdrawalRequestParams(
        amount: pending.amount,
        payoutMethod: pending.payoutMethod,
      ),
    );
  }

  Future<bool> _send(HostWithdrawalRequestParams params) async {
    emit(
      state.copyWith(
        requestStatus: HostWalletRequestStatus.submitting,
        requestMessage: '',
      ),
    );

    final result = await _requestWithdrawal(params);
    final unconfirmed = await _getUnconfirmed();
    if (isClosed) return result.isRight();

    result.fold(
      (failure) => emit(
        state.copyWith(
          requestStatus: HostWalletRequestStatus.failure,
          requestMessage: unconfirmed != null
              ? AppTexts.withdrawalUnconfirmed
              : failure.message,
          unconfirmedRequest: unconfirmed,
          clearUnconfirmedRequest: unconfirmed == null,
        ),
      ),
      (_) => emit(
        state.copyWith(
          requestStatus: HostWalletRequestStatus.success,
          withdrawalAmount: '',
          requestMessage: '',
          clearUnconfirmedRequest: true,
        ),
      ),
    );

    // Success or not, the server's view (balance, pending/processing,
    // eligibility) may have changed — never assume it. A poll started
    // before the POST answered may hold pre-request data, so let it finish
    // and load again rather than sharing it.
    await _loadInFlight;
    await loadWallet();
    return result.isRight();
  }

  void _onNotification(NotificationEntity notification) {
    final text = '${notification.type} ${notification.title}'.toLowerCase();
    if (text.contains('withdraw') || text.contains('payout')) {
      loadWallet();
    }
  }

  /// Polls only while a withdrawal is `processing` and the app is in the
  /// foreground; there is no payout socket event to wait for instead.
  void _syncPolling() {
    final shouldPoll =
        !isClosed &&
        _appInForeground &&
        (state.overview?.hasProcessingWithdrawal ?? false);
    if (!shouldPoll) {
      _pollTimer?.cancel();
      _pollTimer = null;
      return;
    }
    _pollTimer ??= Timer.periodic(processingPollInterval, (_) => loadWallet());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _appInForeground = true;
      loadWallet();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _appInForeground = false;
      _syncPolling();
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _notificationSub?.cancel();
    return super.close();
  }
}

String _inr(double value) => IndianNumberFormat.format(value);

/// Host-facing text for [HostWalletState.withdrawalBlock].
String? withdrawalBlockMessage(HostWalletState state) {
  return switch (state.withdrawalBlock) {
    null => null,
    WithdrawalBlock.balanceMismatch => AppTexts.withdrawBlockedBalanceMismatch,
    WithdrawalBlock.unconfirmedRequest => AppTexts.withdrawalUnconfirmedNotice(
      _inr(state.unconfirmedRequest!.amount),
    ),
    WithdrawalBlock.hostInactive => AppTexts.withdrawBlockedHostInactive,
    WithdrawalBlock.hostNotApproved => AppTexts.withdrawBlockedHostNotApproved,
    WithdrawalBlock.pendingWithdrawal => AppTexts.withdrawBlockedPending,
    WithdrawalBlock.noVerifiedAccount =>
      AppTexts.withdrawBlockedNoVerifiedAccount,
    WithdrawalBlock.belowMinimum => AppTexts.withdrawBlockedBelowMinimum(
      _inr(state.minWithdrawalAmount),
    ),
    WithdrawalBlock.ineligible =>
      state.ineligibleMessage ?? AppTexts.withdrawBlockedGeneric,
  };
}

/// Host-facing text for [HostWalletState.amountError].
String? amountErrorMessage(HostWalletState state) {
  return switch (state.amountError) {
    null => null,
    WithdrawalAmountError.empty => AppTexts.amountErrorEmpty,
    WithdrawalAmountError.invalid => AppTexts.amountErrorInvalid,
    WithdrawalAmountError.tooManyDecimals => AppTexts.amountErrorDecimals,
    WithdrawalAmountError.belowMinimum => AppTexts.amountErrorBelowMinimum(
      _inr(state.minWithdrawalAmount),
    ),
    WithdrawalAmountError.aboveBalance => AppTexts.amountErrorAboveBalance(
      _inr(state.availableBalance),
    ),
  };
}
