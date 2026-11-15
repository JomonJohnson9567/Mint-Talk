import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_wallet_entities.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/pending_withdrawal_request.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/withdrawal_amount_validator.dart';

enum HostWalletStatus { initial, loading, loaded, failure }

enum HostWalletRequestStatus { idle, submitting, success, failure }

/// Why the "Withdraw money" action is unavailable, in priority order.
enum WithdrawalBlock {
  balanceMismatch,

  /// An earlier request's outcome is unknown — the action becomes Retry.
  unconfirmedRequest,
  hostInactive,
  hostNotApproved,
  pendingWithdrawal,
  noVerifiedAccount,
  belowMinimum,
  ineligible,
}

class HostWalletState extends Equatable {
  final HostWalletStatus status;
  final HostWalletRequestStatus requestStatus;
  final HostWalletOverviewEntity? overview;

  /// Load failure, shown only when there is no overview to display.
  final String errorMessage;

  /// Submit failure (backend validation/conflict message or our own).
  final String requestMessage;
  final String withdrawalAmount;

  /// `bank_transfer` / `upi` of the chosen verified account.
  final String? selectedPayoutMethod;
  final PendingWithdrawalRequest? unconfirmedRequest;

  const HostWalletState({
    this.status = HostWalletStatus.initial,
    this.requestStatus = HostWalletRequestStatus.idle,
    this.overview,
    this.errorMessage = '',
    this.requestMessage = '',
    this.withdrawalAmount = '',
    this.selectedPayoutMethod,
    this.unconfirmedRequest,
  });

  HostWalletState copyWith({
    HostWalletStatus? status,
    HostWalletRequestStatus? requestStatus,
    HostWalletOverviewEntity? overview,
    String? errorMessage,
    String? requestMessage,
    String? withdrawalAmount,
    String? selectedPayoutMethod,
    bool clearSelectedPayoutMethod = false,
    PendingWithdrawalRequest? unconfirmedRequest,
    bool clearUnconfirmedRequest = false,
  }) {
    return HostWalletState(
      status: status ?? this.status,
      requestStatus: requestStatus ?? this.requestStatus,
      overview: overview ?? this.overview,
      errorMessage: errorMessage ?? this.errorMessage,
      requestMessage: requestMessage ?? this.requestMessage,
      withdrawalAmount: withdrawalAmount ?? this.withdrawalAmount,
      selectedPayoutMethod: clearSelectedPayoutMethod
          ? null
          : selectedPayoutMethod ?? this.selectedPayoutMethod,
      unconfirmedRequest: clearUnconfirmedRequest
          ? null
          : unconfirmedRequest ?? this.unconfirmedRequest,
    );
  }

  double get availableBalance => overview?.withdrawableBalance ?? 0;

  double get minWithdrawalAmount => overview?.minWithdrawalAmount ?? 0;

  HostWalletSummaryEntity get summary =>
      overview?.summary ?? const HostWalletSummaryEntity();

  List<HostWithdrawalEntryEntity> get withdrawals =>
      overview?.withdrawals ?? const [];

  List<PayoutAccountEntity> get payoutAccounts =>
      overview?.payoutAccounts ?? const [];

  bool get isSubmitting => requestStatus == HostWalletRequestStatus.submitting;

  WithdrawalAmountError? get amountError => WithdrawalAmountValidator.validate(
    withdrawalAmount,
    minimum: minWithdrawalAmount,
    available: availableBalance,
  );

  /// First reason the host can't start a new withdrawal, or null. Based on
  /// the last refresh only — the server re-checks every request.
  WithdrawalBlock? get withdrawalBlock {
    final overview = this.overview;
    if (overview == null) return null;
    final eligibility = overview.eligibility;

    if (overview.requiresBalanceReconciliation) {
      return WithdrawalBlock.balanceMismatch;
    }
    if (unconfirmedRequest != null) return WithdrawalBlock.unconfirmedRequest;
    if (eligibility.hasReason(WithdrawalReasonCode.hostInactive)) {
      return WithdrawalBlock.hostInactive;
    }
    if (eligibility.hasReason(WithdrawalReasonCode.hostNotApproved)) {
      return WithdrawalBlock.hostNotApproved;
    }
    if (overview.hasPendingWithdrawal) return WithdrawalBlock.pendingWithdrawal;
    if (overview.selectableAccounts.isEmpty ||
        eligibility.hasReason(WithdrawalReasonCode.payoutAccountNotVerified)) {
      return WithdrawalBlock.noVerifiedAccount;
    }
    if (eligibility.hasReason(WithdrawalReasonCode.belowMinimum) ||
        (overview.withdrawableBalance * 100).round() <
            (overview.minWithdrawalAmount * 100).round() ||
        overview.withdrawableBalance <= 0) {
      return WithdrawalBlock.belowMinimum;
    }
    if (!eligibility.eligible) return WithdrawalBlock.ineligible;
    return null;
  }

  /// Backend explanation for [WithdrawalBlock.ineligible], when it sent one.
  String? get ineligibleMessage {
    final reasons = overview?.eligibility.reasons ?? const [];
    for (final reason in reasons) {
      if (reason.message != null) return reason.message;
    }
    return null;
  }

  bool get canSubmit =>
      !isSubmitting &&
      withdrawalBlock == null &&
      amountError == null &&
      selectedPayoutMethod != null;

  @override
  List<Object?> get props => [
    status,
    requestStatus,
    overview,
    errorMessage,
    requestMessage,
    withdrawalAmount,
    selectedPayoutMethod,
    unconfirmedRequest,
  ];
}
