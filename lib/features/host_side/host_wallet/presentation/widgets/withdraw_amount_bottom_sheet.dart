import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_cubit.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_state.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/host_wallet_bottom_sheet_presenter.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/wallet_sheet_handle.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/bank_account_card.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/wallet_text_field.dart';

class WithdrawAmountBottomSheet extends StatelessWidget {
  final BuildContext rootContext;

  const WithdrawAmountBottomSheet({
    super.key,
    required this.rootContext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WalletSheetHandle(),
              SizedBox(height: 18.h),
              Text(
                'Withdraw Amount',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Enter the amount you want to withdraw.',
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.4,
                  color: AppColors.subtitleText,
                ),
              ),
              SizedBox(height: 16.h),
              const Divider(height: 1),
              SizedBox(height: 16.h),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: BlocBuilder<HostWalletCubit, HostWalletState>(
                    builder: (context, state) {
                      final selectedBank = state.selectedBankAccount;
                      final isUpi = state.payoutMethod == 'upi';
                      final amountText = state.withdrawalAmount.trim();
                      final amount = double.tryParse(amountText) ?? 0.0;
                      final hasValidDestination =
                          isUpi ? state.upiId.trim().isNotEmpty : selectedBank != null;
                      final isButtonEnabled = amount >= 500 &&
                          amount <= state.availableBalance &&
                          hasValidDestination &&
                          state.requestStatus != HostWalletRequestStatus.submitting;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Withdrawal Amount',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          TextFormField(
                            initialValue: state.withdrawalAmount,
                            keyboardType: TextInputType.number,
                            onChanged: context.read<HostWalletCubit>().updateWithdrawalAmount,
                            decoration: InputDecoration(
                              hintText: 'Enter amount',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 16.h,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7F7F7),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.r),
                                borderSide: BorderSide(color: AppColors.borderSoft, width: 1.2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.r),
                                borderSide: BorderSide(color: AppColors.borderSoft, width: 1.2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.r),
                                borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.4),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          _buildAmountTagMessage(state, amount),
                          SizedBox(height: 16.h),
                          Text(
                            'Withdraw To',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          _PayoutMethodToggle(
                            selectedMethod: state.payoutMethod,
                            onChanged: context.read<HostWalletCubit>().selectPayoutMethod,
                          ),
                          SizedBox(height: 14.h),
                          if (isUpi)
                            WalletTextField(
                              label: 'UPI ID',
                              hintText: 'e.g. yourname@upi',
                              initialValue: state.upiId,
                              onChanged: context.read<HostWalletCubit>().updateUpiId,
                            )
                          else ...[
                            if (selectedBank != null)
                              BankAccountCard(
                                bankAccount: selectedBank,
                                isSelected: true,
                                onTap: () {},
                              )
                            else
                              _NoBankSelected(onChangeBank: () => _changeBank(context)),
                            SizedBox(height: 14.h),
                            TextButton(
                              onPressed: () => _changeBank(context),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                foregroundColor: AppColors.primaryColor,
                              ),
                              child: Text(
                                'Change Bank Account',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: 18.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0D9),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: const Color(0xFFF6C36A)),
                            ),
                            child: Text(
                              'Available Balance: ₹ ${state.availableBalance}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFEE7A22),
                              ),
                            ),
                          ),
                          if (state.errorMessage.isNotEmpty) ...[
                            SizedBox(height: 14.h),
                            _ErrorBanner(message: state.errorMessage),
                          ],
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: Size.fromHeight(54.h),
                                    side: const BorderSide(color: Color(0xFFBFBFBF)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isButtonEnabled
                                      ? () => _submitWithdrawal(context)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: AppColors.white,
                                    disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.2),
                                    disabledForegroundColor: AppColors.subtitleText,
                                    minimumSize: Size.fromHeight(54.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Withdraw',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changeBank(BuildContext context) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (rootContext.mounted) {
        HostWalletBottomSheetPresenter.showSelectBankSheet(rootContext);
      }
    });
  }

  Future<void> _submitWithdrawal(BuildContext context) async {
    final submitted = await context.read<HostWalletCubit>().submitWithdrawalRequest();
    if (!submitted || !context.mounted) {
      return;
    }

    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (rootContext.mounted) {
        HostWalletBottomSheetPresenter.showWithdrawalSuccessSheet(rootContext);
      }
    });
  }

  Widget _buildAmountTagMessage(HostWalletState state, double amount) {
    if (state.withdrawalAmount.trim().isEmpty) {
      return Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 14.sp, color: AppColors.subtitleText),
          SizedBox(width: 6.w),
          Text(
            'Minimum withdrawal amount is ₹500.',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.subtitleText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (amount < 500) {
      return Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 14.sp, color: AppColors.orange),
          SizedBox(width: 6.w),
          Text(
            'Minimum withdrawal amount is ₹500.',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (amount > state.availableBalance) {
      return Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 14.sp, color: AppColors.red),
          SizedBox(width: 6.w),
          Text(
            'Amount exceeds available balance of ₹${state.availableBalance}.',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(Icons.check_circle_outline_rounded, size: 14.sp, color: AppColors.green),
        SizedBox(width: 6.w),
        Text(
          'Valid withdrawal amount.',
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PayoutMethodToggle extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onChanged;

  const _PayoutMethodToggle({required this.selectedMethod, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          _PayoutMethodOption(
            label: 'Bank Transfer',
            isSelected: selectedMethod == 'bank_transfer',
            onTap: () => onChanged('bank_transfer'),
          ),
          _PayoutMethodOption(
            label: 'UPI',
            isSelected: selectedMethod == 'upi',
            onTap: () => onChanged('upi'),
          ),
        ],
      ),
    );
  }
}

class _PayoutMethodOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PayoutMethodOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : AppColors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.white : AppColors.subtitleText,
            ),
          ),
        ),
      ),
    );
  }
}

class _NoBankSelected extends StatelessWidget {
  final VoidCallback onChangeBank;

  const _NoBankSelected({required this.onChangeBank});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChangeBank,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF3),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFF1C26B)),
        ),
        child: Text(
          'No bank account selected. Tap to choose one.',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFFC9C9)),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.red,
        ),
      ),
    );
  }
}
