import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_cubit.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_state.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_bank_account.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/bank_account_card.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/host_wallet_bottom_sheet_presenter.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/wallet_sheet_handle.dart';

class SelectBankBottomSheet extends StatelessWidget {
  final BuildContext rootContext;

  const SelectBankBottomSheet({
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
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
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
                'Select Bank Account',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Choose a bank account to receive your withdrawal.',
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.4,
                  color: AppColors.subtitleText,
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: BlocBuilder<HostWalletCubit, HostWalletState>(
                  builder: (context, state) {
                    if (state.bankAccounts.isEmpty) {
                      return _EmptyState(
                        onAddBank: () => _replaceWithAddBank(context),
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.bankAccounts.length + 1,
                      separatorBuilder: (context, index) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        if (index == state.bankAccounts.length) {
                          return _AddBankButton(
                            onTap: () => _replaceWithAddBank(context),
                          );
                        }

                        final bankAccount = state.bankAccounts[index];
                        return BankAccountCard(
                          bankAccount: bankAccount,
                          isSelected: state.selectedBankAccount?.id == bankAccount.id,
                          onTap: () => _selectBank(context, bankAccount),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectBank(BuildContext context, HostBankAccount bankAccount) {
    context.read<HostWalletCubit>().selectBankAccount(bankAccount);
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (rootContext.mounted) {
        HostWalletBottomSheetPresenter.showWithdrawAmountSheet(rootContext);
      }
    });
  }

  void _replaceWithAddBank(BuildContext context) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (rootContext.mounted) {
        HostWalletBottomSheetPresenter.showAddBankSheet(rootContext);
      }
    });
  }
}

class _AddBankButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddBankButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFF),
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, color: AppColors.primaryColor, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Add New Bank Account',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: AppColors.subtitleText),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddBank;

  const _EmptyState({required this.onAddBank});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_outlined, size: 52.sp, color: AppColors.subtitleText),
          SizedBox(height: 12.h),
          Text(
            'No bank accounts added yet.',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add a bank account to continue with withdrawals.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.subtitleText,
            ),
          ),
          SizedBox(height: 18.h),
          _AddBankButton(onTap: onAddBank),
        ],
      ),
    );
  }
}
