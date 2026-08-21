import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_bank_account.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_wallet_entities.dart';

enum HostWalletStatus { initial, loading, loaded, failure }
enum HostWalletRequestStatus { idle, submitting, success, failure }

class HostWalletState extends Equatable {
  final HostWalletStatus status;
  final HostWalletRequestStatus requestStatus;
  final HostWalletOverviewEntity? overview;
  final List<HostBankAccount> bankAccounts;
  final HostBankAccount? selectedBankAccount;
  final String accountHolderName;
  final String accountNumber;
  final String confirmAccountNumber;
  final String ifscCode;
  final String bankName;
  final String branchName;
  final String withdrawalAmount;
  final String errorMessage;
  final String payoutMethod;
  final String upiId;

  const HostWalletState({
    this.status = HostWalletStatus.initial,
    this.requestStatus = HostWalletRequestStatus.idle,
    this.overview,
    this.bankAccounts = const [],
    this.selectedBankAccount,
    this.accountHolderName = '',
    this.accountNumber = '',
    this.confirmAccountNumber = '',
    this.ifscCode = '',
    this.bankName = '',
    this.branchName = '',
    this.withdrawalAmount = '',
    this.errorMessage = '',
    this.payoutMethod = 'bank_transfer',
    this.upiId = '',
  });

  HostWalletState copyWith({
    HostWalletStatus? status,
    HostWalletRequestStatus? requestStatus,
    HostWalletOverviewEntity? overview,
    List<HostBankAccount>? bankAccounts,
    HostBankAccount? selectedBankAccount,
    String? accountHolderName,
    String? accountNumber,
    String? confirmAccountNumber,
    String? ifscCode,
    String? bankName,
    String? branchName,
    String? withdrawalAmount,
    String? errorMessage,
    String? payoutMethod,
    String? upiId,
  }) {
    return HostWalletState(
      status: status ?? this.status,
      requestStatus: requestStatus ?? this.requestStatus,
      overview: overview ?? this.overview,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      selectedBankAccount: selectedBankAccount ?? this.selectedBankAccount,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      confirmAccountNumber: confirmAccountNumber ?? this.confirmAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      withdrawalAmount: withdrawalAmount ?? this.withdrawalAmount,
      errorMessage: errorMessage ?? this.errorMessage,
      payoutMethod: payoutMethod ?? this.payoutMethod,
      upiId: upiId ?? this.upiId,
    );
  }

  int get availableBalance => overview?.withdrawableBalance ?? 0;

  List<HostWithdrawalEntryEntity> get withdrawals =>
      overview?.withdrawals ?? const [];

  int get approvedTotal => overview?.approvedTotal ?? 0;

  int get pendingTotal => overview?.pendingTotal ?? 0;

  int get totalWithdrawn =>
      withdrawals.fold<int>(0, (sum, item) => sum + item.amount.round());

  @override
  List<Object?> get props => [
        status,
        requestStatus,
        overview,
        bankAccounts,
        selectedBankAccount,
        accountHolderName,
        accountNumber,
        confirmAccountNumber,
        ifscCode,
        bankName,
        branchName,
        withdrawalAmount,
        errorMessage,
        payoutMethod,
        upiId,
      ];
}
