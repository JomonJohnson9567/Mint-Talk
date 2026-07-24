import 'package:equatable/equatable.dart';

class HostWithdrawalEntryEntity extends Equatable {
  final String id;
  final double amount;
  final String payoutMethod;
  final String status;
  final DateTime createdAt;

  const HostWithdrawalEntryEntity({
    required this.id,
    required this.amount,
    required this.payoutMethod,
    required this.status,
    required this.createdAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';

  @override
  List<Object?> get props => [id, amount, payoutMethod, status, createdAt];
}

class HostWalletOverviewEntity extends Equatable {
  final int withdrawableBalance;
  final List<HostWithdrawalEntryEntity> withdrawals;
  final int page;
  final int limit;
  final int total;

  const HostWalletOverviewEntity({
    required this.withdrawableBalance,
    required this.withdrawals,
    required this.page,
    required this.limit,
    required this.total,
  });

  int get pendingTotal =>
      withdrawals.where((item) => item.isPending).fold<int>(
            0,
            (sum, item) => sum + item.amount.round(),
          );

  int get approvedTotal =>
      withdrawals.where((item) => item.isApproved).fold<int>(
            0,
            (sum, item) => sum + item.amount.round(),
          );

  @override
  List<Object?> get props => [withdrawableBalance, withdrawals, page, limit, total];
}

class HostWithdrawalRequestParams extends Equatable {
  final double amount;
  final String payoutMethod;
  final String? bankName;
  final String? accountNumber;
  final String? ifsc;
  final String? holderName;
  final String? upiId;

  const HostWithdrawalRequestParams({
    required this.amount,
    required this.payoutMethod,
    this.bankName,
    this.accountNumber,
    this.ifsc,
    this.holderName,
    this.upiId,
  });

  @override
  List<Object?> get props => [
        amount,
        payoutMethod,
        bankName,
        accountNumber,
        ifsc,
        holderName,
        upiId,
      ];
}
