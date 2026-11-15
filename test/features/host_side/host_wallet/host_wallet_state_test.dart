import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_wallet_entities.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/pending_withdrawal_request.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_state.dart';

const _verifiedBank = PayoutAccountEntity(
  id: 'a1',
  method: PayoutMethod.bankTransfer,
  label: 'HDFC',
  maskedDetail: '••••6789',
  status: 'verified',
  active: true,
);

HostWalletState _state({
  double balance = 100,
  List<PayoutAccountEntity> accounts = const [_verifiedBank],
  HostWalletSummaryEntity summary = const HostWalletSummaryEntity(),
  WithdrawalEligibilityEntity eligibility = const WithdrawalEligibilityEntity(),
  List<HostWithdrawalEntryEntity> withdrawals = const [],
  PendingWithdrawalRequest? unconfirmed,
  String amount = '',
}) {
  return HostWalletState(
    status: HostWalletStatus.loaded,
    overview: HostWalletOverviewEntity(
      withdrawableBalance: balance,
      minWithdrawalAmount: 100,
      summary: summary,
      payoutAccounts: accounts,
      eligibility: eligibility,
      withdrawals: withdrawals,
      page: 1,
      limit: 20,
      total: withdrawals.length,
    ),
    withdrawalAmount: amount,
    selectedPayoutMethod: accounts.any((a) => a.isSelectable)
        ? PayoutMethod.bankTransfer
        : null,
    unconfirmedRequest: unconfirmed,
  );
}

void main() {
  test('balance ₹99 with ₹100 minimum is unavailable', () {
    expect(_state(balance: 99).withdrawalBlock, WithdrawalBlock.belowMinimum);
  });

  test('balance ₹100 allows exactly ₹100', () {
    final state = _state(balance: 100, amount: '100');
    expect(state.withdrawalBlock, isNull);
    expect(state.canSubmit, isTrue);
  });

  test('balance mismatch disables withdrawal first', () {
    final state = _state(
      summary: const HostWalletSummaryEntity(balanceMismatch: true),
      withdrawals: [
        HostWithdrawalEntryEntity(
          id: 'w',
          amount: 100,
          payoutMethod: PayoutMethod.upi,
          status: WithdrawalStatus.pending,
          createdAt: DateTime(2026),
        ),
      ],
    );
    expect(state.withdrawalBlock, WithdrawalBlock.balanceMismatch);
  });

  test('an existing pending request blocks another', () {
    final state = _state(
      balance: 500,
      eligibility: const WithdrawalEligibilityEntity(
        eligible: false,
        reasons: [WithdrawalIneligibilityReason(code: 'PENDING_WITHDRAWAL')],
      ),
    );
    expect(state.withdrawalBlock, WithdrawalBlock.pendingWithdrawal);
  });

  test('unverified or disabled accounts are not enough', () {
    final state = _state(
      accounts: const [
        PayoutAccountEntity(
          id: 'a',
          method: PayoutMethod.upi,
          label: 'UPI',
          maskedDetail: 'na•••@bank',
          status: 'pending_verification',
          active: true,
        ),
        PayoutAccountEntity(
          id: 'b',
          method: PayoutMethod.bankTransfer,
          label: 'HDFC',
          maskedDetail: '••••1234',
          status: 'verified',
          active: false,
        ),
      ],
    );
    expect(state.withdrawalBlock, WithdrawalBlock.noVerifiedAccount);
    expect(state.canSubmit, isFalse);
  });

  test('an unconfirmed request turns the action into a retry', () {
    final state = _state(
      unconfirmed: PendingWithdrawalRequest(
        idempotencyKey: 'k',
        amount: 100,
        payoutMethod: PayoutMethod.bankTransfer,
        createdAt: DateTime(2026),
      ),
    );
    expect(state.withdrawalBlock, WithdrawalBlock.unconfirmedRequest);
  });

  test('cannot submit while a request is in flight', () {
    final state = _state(
      amount: '100',
    ).copyWith(requestStatus: HostWalletRequestStatus.submitting);
    expect(state.canSubmit, isFalse);
  });
}
