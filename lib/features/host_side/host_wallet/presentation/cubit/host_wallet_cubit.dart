import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_wallet_entities.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/usecases/get_host_wallet_overview_usecase.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/usecases/request_withdrawal_usecase.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_bank_account.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_state.dart';

@injectable
class HostWalletCubit extends Cubit<HostWalletState> {
  final GetHostWalletOverviewUseCase getHostWalletOverviewUseCase;
  final RequestWithdrawalUseCase requestWithdrawalUseCase;

  HostWalletCubit(
    this.getHostWalletOverviewUseCase,
    this.requestWithdrawalUseCase,
  )
      : super(
          const HostWalletState(
            bankAccounts: [
              HostBankAccount(
                id: 'bank_1',
                accountHolderName: 'Remani Nair',
                accountNumber: '9876543456',
                ifscCode: 'SBIN0001234',
                bankName: 'State Bank Of India',
                branchName: 'Kochi Main Branch',
              ),
              HostBankAccount(
                id: 'bank_2',
                accountHolderName: 'Anjali Jose',
                accountNumber: '6543217890',
                ifscCode: 'HDFC0002456',
                bankName: 'HDFC Bank',
                branchName: 'Thrissur Town Branch',
              ),
            ],
          ),
        );

  Future<void> loadWallet() async {
    emit(state.copyWith(status: HostWalletStatus.loading, errorMessage: ''));
    final result = await getHostWalletOverviewUseCase(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HostWalletStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (overview) => emit(
        state.copyWith(
          status: HostWalletStatus.loaded,
          overview: overview,
        ),
      ),
    );
  }

  void selectBankAccount(HostBankAccount bankAccount) {
    emit(
      state.copyWith(
        selectedBankAccount: bankAccount,
        errorMessage: '',
      ),
    );
  }

  void updateAccountHolderName(String value) {
    emit(state.copyWith(accountHolderName: value, errorMessage: ''));
  }

  void updateAccountNumber(String value) {
    emit(state.copyWith(accountNumber: value, errorMessage: ''));
  }

  void updateConfirmAccountNumber(String value) {
    emit(state.copyWith(confirmAccountNumber: value, errorMessage: ''));
  }

  void updateIfscCode(String value) {
    emit(state.copyWith(ifscCode: value.toUpperCase(), errorMessage: ''));
  }

  void updateBankName(String value) {
    emit(state.copyWith(bankName: value, errorMessage: ''));
  }

  void updateBranchName(String value) {
    emit(state.copyWith(branchName: value, errorMessage: ''));
  }

  void updateWithdrawalAmount(String value) {
    emit(state.copyWith(withdrawalAmount: value, errorMessage: ''));
  }

  void clearBankForm() {
    emit(
      state.copyWith(
        accountHolderName: '',
        accountNumber: '',
        confirmAccountNumber: '',
        ifscCode: '',
        bankName: '',
        branchName: '',
        errorMessage: '',
      ),
    );
  }

  bool addBankAccount() {
    final accountHolderName = state.accountHolderName.trim();
    final accountNumber = state.accountNumber.trim();
    final confirmAccountNumber = state.confirmAccountNumber.trim();
    final ifscCode = state.ifscCode.trim();
    final bankName = state.bankName.trim();
    final branchName = state.branchName.trim();

    if (accountHolderName.isEmpty ||
        accountNumber.isEmpty ||
        confirmAccountNumber.isEmpty ||
        ifscCode.isEmpty ||
        bankName.isEmpty ||
        branchName.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please fill all the bank details.'));
      return false;
    }

    if (accountNumber != confirmAccountNumber) {
      emit(state.copyWith(errorMessage: 'Account numbers do not match.'));
      return false;
    }

    final newBankAccount = HostBankAccount(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      accountHolderName: accountHolderName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      bankName: bankName,
      branchName: branchName,
    );

    emit(
      state.copyWith(
        bankAccounts: [...state.bankAccounts, newBankAccount],
        selectedBankAccount: newBankAccount,
        errorMessage: '',
      ),
    );
    clearBankForm();
    return true;
  }

  Future<bool> submitWithdrawalRequest() async {
    final selectedBank = state.selectedBankAccount;
    final amountText = state.withdrawalAmount.trim();

    if (selectedBank == null) {
      emit(state.copyWith(errorMessage: 'Please select a bank account.'));
      return false;
    }

    if (amountText.isEmpty) {
      emit(state.copyWith(errorMessage: 'Enter a withdrawal amount.'));
      return false;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      emit(state.copyWith(errorMessage: 'Enter a valid withdrawal amount.'));
      return false;
    }

    if (amount > state.availableBalance) {
      emit(state.copyWith(errorMessage: 'Amount exceeds available balance.'));
      return false;
    }

    emit(
      state.copyWith(
        requestStatus: HostWalletRequestStatus.submitting,
        errorMessage: '',
      ),
    );

    final result = await requestWithdrawalUseCase(
      HostWithdrawalRequestParams(
        amount: amount,
        payoutMethod: 'bank_transfer',
        bankName: selectedBank.bankName,
        accountNumber: selectedBank.accountNumber,
        ifsc: selectedBank.ifscCode,
        holderName: selectedBank.accountHolderName,
      ),
    );

    return await result.fold<Future<bool>>(
      (failure) async {
        emit(
          state.copyWith(
            requestStatus: HostWalletRequestStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return false;
      },
      (_) async {
        emit(
          state.copyWith(
            requestStatus: HostWalletRequestStatus.success,
            withdrawalAmount: '',
            errorMessage: '',
          ),
        );
        await loadWallet();
        return true;
      },
    );
  }

  String get maskedSelectedAccountNumber =>
      state.selectedBankAccount?.maskedAccountNumber ?? '';
}
