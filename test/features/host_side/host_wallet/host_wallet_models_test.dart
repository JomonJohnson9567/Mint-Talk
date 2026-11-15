import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/host_side/host_wallet/data/models/host_wallet_models.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_wallet_entities.dart';

void main() {
  group('HostWalletOverviewModel.fromJson', () {
    final json = {
      'status': 'success',
      'data': {
        'withdrawableBalance': 1234.5,
        'minWithdrawalAmount': 100,
        'summary': {
          'totalNetINR': 5000,
          'pendingINR': 200,
          'processingINR': 300.25,
          'paidINR': 1000,
          'reservedINR': 500.25,
          'legacyHeldINR': 0,
          'balanceMismatch': false,
        },
        'payoutAccounts': [
          {
            '_id': 'a1',
            'payoutMethod': 'bank_transfer',
            'maskedDetails': {'bankName': 'HDFC', 'accountNumber': 'XXXX6789'},
            'status': 'verified',
            'active': true,
          },
          {
            '_id': 'a2',
            'payoutMethod': 'upi',
            'maskedDetails': {'upiId': 'na***@bank'},
            'status': 'pending_verification',
            'active': true,
          },
        ],
        'withdrawalEligibility': {
          'eligible': false,
          'reasons': [
            'PENDING_WITHDRAWAL',
            {'code': 'BELOW_MINIMUM', 'message': 'Below the minimum'},
          ],
        },
        'withdrawals': [
          for (final status in [
            'pending',
            'processing',
            'paid',
            'rejected',
            'failed',
            'reversed',
            'approved',
            'mystery',
          ])
            {
              '_id': status,
              'amount': 100.5,
              'payoutMethod': 'upi',
              'status': status,
              'createdAt': '2026-11-01T10:00:00.000Z',
              if (status == 'rejected') 'rejectionReason': 'KYC mismatch',
            },
        ],
        'page': 1,
        'limit': 20,
        'total': 8,
      },
    };

    final overview = HostWalletOverviewModel.fromJson(json);

    test('reads balances and summary without rounding', () {
      expect(overview.withdrawableBalance, 1234.5);
      expect(overview.minWithdrawalAmount, 100);
      expect(overview.summary.processingInr, 300.25);
      expect(overview.summary.reservedInr, 500.25);
      expect(overview.summary.balanceMismatch, isFalse);
    });

    test('only verified + active accounts are selectable', () {
      expect(overview.payoutAccounts, hasLength(2));
      expect(overview.selectableAccounts.map((a) => a.id), ['a1']);
      expect(overview.payoutAccounts.first.label, 'HDFC');
      expect(overview.payoutAccounts.first.maskedDetail, 'XXXX6789');
      expect(overview.payoutAccounts.last.maskedDetail, 'na***@bank');
    });

    test('parses string and object eligibility reasons', () {
      expect(overview.eligibility.eligible, isFalse);
      expect(
        overview.eligibility.hasReason(WithdrawalReasonCode.pendingWithdrawal),
        isTrue,
      );
      expect(overview.eligibility.reasons.last.message, 'Below the minimum');
      expect(overview.hasPendingWithdrawal, isTrue);
    });

    test('maps every backend status; unknown values do not crash', () {
      expect(overview.withdrawals.map((w) => w.status), [
        WithdrawalStatus.pending,
        WithdrawalStatus.processing,
        WithdrawalStatus.paid,
        WithdrawalStatus.rejected,
        WithdrawalStatus.failed,
        WithdrawalStatus.reversed,
        WithdrawalStatus.approved,
        WithdrawalStatus.unknown,
      ]);
      expect(overview.withdrawals[3].reason, 'KYC mismatch');
      expect(overview.hasProcessingWithdrawal, isTrue);
    });

    test('missing optional blocks fall back safely', () {
      final bare = HostWalletOverviewModel.fromJson({
        'data': {'withdrawableBalance': 50, 'withdrawals': []},
      });
      expect(bare.eligibility.eligible, isTrue);
      expect(bare.payoutAccounts, isEmpty);
      expect(bare.minWithdrawalAmount, 0);
      expect(bare.summary.balanceMismatch, isFalse);
    });

    test('balanceMismatch requires reconciliation', () {
      final mismatch = HostWalletOverviewModel.fromJson({
        'data': {
          'withdrawableBalance': 500,
          'summary': {'balanceMismatch': true},
        },
      });
      expect(mismatch.requiresBalanceReconciliation, isTrue);
    });
  });

  group('payout masking', () {
    test('raw payoutDetails in history are masked before reaching the UI', () {
      final bank = HostWithdrawalEntryModel.fromJson({
        'status': 'paid',
        'payoutDetails': {'accountNumber': '0765432123456789', 'ifsc': 'X'},
      });
      expect(bank.maskedDestination, '••••6789');

      final upi = HostWithdrawalEntryModel.fromJson({
        'status': 'paid',
        'payoutDetails': {'upiId': 'alex@okaxis'},
      });
      expect(upi.maskedDestination, 'al•••@okaxis');
    });

    test('API-masked details pass through untouched', () {
      final entry = HostWithdrawalEntryModel.fromJson({
        'status': 'paid',
        'maskedDetails': 'HDFC ••••6789',
      });
      expect(entry.maskedDestination, 'HDFC ••••6789');
    });
  });

  group('HostWithdrawalRequestModel.toJson', () {
    test('sends only amount and payoutMethod', () {
      const model = HostWithdrawalRequestModel(
        amount: 100,
        payoutMethod: PayoutMethod.bankTransfer,
      );
      expect(model.toJson(), {'amount': 100, 'payoutMethod': 'bank_transfer'});
      expect(model.toJson()['amount'], isA<int>());
    });

    test('keeps two decimals', () {
      const model = HostWithdrawalRequestModel(
        amount: 150.5,
        payoutMethod: PayoutMethod.upi,
      );
      expect(model.toJson(), {'amount': 150.5, 'payoutMethod': 'upi'});
    });
  });
}
