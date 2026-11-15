import 'package:equatable/equatable.dart';

/// Payout methods the backend accepts in `payoutMethod`.
abstract final class PayoutMethod {
  static const String bankTransfer = 'bank_transfer';
  static const String upi = 'upi';
}

/// Lifecycle of a withdrawal as reported by the backend. Every transition
/// happens server-side (admin review, RazorpayX webhooks); the app only
/// displays it.
enum WithdrawalStatus {
  pending,
  processing,
  paid,
  rejected,
  failed,
  reversed,

  /// Historical status from before the RazorpayX flow — the request is under
  /// reconciliation and must never be shown as paid.
  approved,
  unknown;

  static WithdrawalStatus fromApi(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    return WithdrawalStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => WithdrawalStatus.unknown,
    );
  }
}

class HostWithdrawalEntryEntity extends Equatable {
  final String id;

  /// INR, up to two decimals.
  final double amount;
  final String payoutMethod;
  final WithdrawalStatus status;
  final DateTime createdAt;

  /// Admin's reason for a `rejected` request (or the failure reason), if any.
  final String? reason;

  /// Already-masked destination (`••••6789`, `na•••@bank`) — raw payout
  /// details are never kept on the entity.
  final String? maskedDestination;

  const HostWithdrawalEntryEntity({
    required this.id,
    required this.amount,
    required this.payoutMethod,
    required this.status,
    required this.createdAt,
    this.reason,
    this.maskedDestination,
  });

  bool get isPending => status == WithdrawalStatus.pending;
  bool get isProcessing => status == WithdrawalStatus.processing;

  @override
  List<Object?> get props => [
    id,
    amount,
    payoutMethod,
    status,
    createdAt,
    reason,
    maskedDestination,
  ];
}

/// Server-computed INR totals for the host. Never derived or adjusted
/// locally.
class HostWalletSummaryEntity extends Equatable {
  final double totalNetInr;
  final double pendingInr;
  final double processingInr;
  final double paidInr;
  final double reservedInr;
  final double legacyHeldInr;

  /// The backend's ledger and balance disagree — withdrawals are disabled
  /// until support reconciles it.
  final bool balanceMismatch;

  const HostWalletSummaryEntity({
    this.totalNetInr = 0,
    this.pendingInr = 0,
    this.processingInr = 0,
    this.paidInr = 0,
    this.reservedInr = 0,
    this.legacyHeldInr = 0,
    this.balanceMismatch = false,
  });

  @override
  List<Object?> get props => [
    totalNetInr,
    pendingInr,
    processingInr,
    paidInr,
    reservedInr,
    legacyHeldInr,
    balanceMismatch,
  ];
}

/// A bank account or UPI ID that admin collected and verified for the host.
/// Hosts never enter these in the app.
class PayoutAccountEntity extends Equatable {
  final String id;
  final String method;

  /// Bank name, or "UPI".
  final String label;

  /// Masked account number / UPI ID exactly as supplied by the API.
  final String maskedDetail;
  final String status;
  final bool active;

  const PayoutAccountEntity({
    required this.id,
    required this.method,
    required this.label,
    required this.maskedDetail,
    required this.status,
    required this.active,
  });

  bool get isVerified => status.toLowerCase() == 'verified';

  /// Only verified, active accounts can receive a withdrawal.
  bool get isSelectable => isVerified && active;

  @override
  List<Object?> get props => [id, method, label, maskedDetail, status, active];
}

/// Backend reason codes for why a withdrawal is currently unavailable.
abstract final class WithdrawalReasonCode {
  static const String hostInactive = 'HOST_INACTIVE';
  static const String hostNotApproved = 'HOST_NOT_APPROVED';
  static const String payoutAccountNotVerified = 'PAYOUT_ACCOUNT_NOT_VERIFIED';
  static const String pendingWithdrawal = 'PENDING_WITHDRAWAL';
  static const String balanceReconciliationRequired =
      'BALANCE_RECONCILIATION_REQUIRED';
  static const String belowMinimum = 'BELOW_MINIMUM';
}

class WithdrawalIneligibilityReason extends Equatable {
  final String code;

  /// Backend-supplied explanation, when the reason came as an object.
  final String? message;

  const WithdrawalIneligibilityReason({required this.code, this.message});

  @override
  List<Object?> get props => [code, message];
}

/// The backend's general checks at load time. Advisory only — eligibility
/// can change before the request is sent, so the POST result is what counts.
class WithdrawalEligibilityEntity extends Equatable {
  final bool eligible;
  final List<WithdrawalIneligibilityReason> reasons;

  const WithdrawalEligibilityEntity({
    this.eligible = true,
    this.reasons = const [],
  });

  bool hasReason(String code) => reasons.any((reason) => reason.code == code);

  @override
  List<Object?> get props => [eligible, reasons];
}

class HostWalletOverviewEntity extends Equatable {
  /// Authoritative available INR.
  final double withdrawableBalance;

  /// Backend-configured minimum; 0 when the API didn't send one (the server
  /// still enforces its own).
  final double minWithdrawalAmount;
  final HostWalletSummaryEntity summary;
  final List<PayoutAccountEntity> payoutAccounts;
  final WithdrawalEligibilityEntity eligibility;
  final List<HostWithdrawalEntryEntity> withdrawals;
  final int page;
  final int limit;
  final int total;

  const HostWalletOverviewEntity({
    required this.withdrawableBalance,
    required this.minWithdrawalAmount,
    required this.summary,
    required this.payoutAccounts,
    required this.eligibility,
    required this.withdrawals,
    required this.page,
    required this.limit,
    required this.total,
  });

  List<PayoutAccountEntity> get selectableAccounts =>
      payoutAccounts.where((account) => account.isSelectable).toList();

  bool get hasPendingWithdrawal =>
      eligibility.hasReason(WithdrawalReasonCode.pendingWithdrawal) ||
      withdrawals.any((item) => item.isPending);

  bool get hasProcessingWithdrawal =>
      withdrawals.any((item) => item.isProcessing);

  bool get requiresBalanceReconciliation =>
      summary.balanceMismatch ||
      eligibility.hasReason(WithdrawalReasonCode.balanceReconciliationRequired);

  @override
  List<Object?> get props => [
    withdrawableBalance,
    minWithdrawalAmount,
    summary,
    payoutAccounts,
    eligibility,
    withdrawals,
    page,
    limit,
    total,
  ];
}

/// The only two fields the withdrawal endpoint accepts.
class HostWithdrawalRequestParams extends Equatable {
  final double amount;
  final String payoutMethod;

  const HostWithdrawalRequestParams({
    required this.amount,
    required this.payoutMethod,
  });

  @override
  List<Object?> get props => [amount, payoutMethod];
}
