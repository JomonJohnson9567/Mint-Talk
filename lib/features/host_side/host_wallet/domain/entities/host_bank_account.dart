import 'package:equatable/equatable.dart';

class HostBankAccount extends Equatable {
  final String id;
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String branchName;

  const HostBankAccount({
    required this.id,
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.branchName,
  });

  String get maskedAccountNumber {
    if (accountNumber.length <= 4) {
      return accountNumber;
    }

    final lastFourDigits = accountNumber.substring(accountNumber.length - 4);
    return '********$lastFourDigits';
  }

  HostBankAccount copyWith({
    String? id,
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? bankName,
    String? branchName,
  }) {
    return HostBankAccount(
      id: id ?? this.id,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        accountHolderName,
        accountNumber,
        ifscCode,
        bankName,
        branchName,
      ];
}
