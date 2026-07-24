import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_cubit.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_state.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/host_wallet_bottom_sheet_presenter.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/wallet_sheet_handle.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/wallet_text_field.dart';

class AddBankBottomSheet extends StatelessWidget {
  final BuildContext rootContext;

  const AddBankBottomSheet({
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
                'Connect Bank Account',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Enter your bank details to process withdrawal.',
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
                      return Column(
                        children: [
                          WalletTextField(
                            label: 'Account Holder Name',
                            hintText: 'Enter account holder name',
                            initialValue: state.accountHolderName,
                            textCapitalizationWords: true,
                            onChanged: context.read<HostWalletCubit>().updateAccountHolderName,
                          ),
                          SizedBox(height: 16.h),
                          WalletTextField(
                            label: 'Account Number',
                            hintText: 'Enter account number',
                            initialValue: state.accountNumber,
                            keyboardType: TextInputType.number,
                            onChanged: context.read<HostWalletCubit>().updateAccountNumber,
                          ),
                          SizedBox(height: 16.h),
                          WalletTextField(
                            label: 'Confirm Account Number',
                            hintText: 'Re-enter account number',
                            initialValue: state.confirmAccountNumber,
                            keyboardType: TextInputType.number,
                            onChanged: context.read<HostWalletCubit>().updateConfirmAccountNumber,
                          ),
                          SizedBox(height: 16.h),
                          WalletTextField(
                            label: 'IFSC Code',
                            hintText: 'Enter IFSC code',
                            initialValue: state.ifscCode,
                            onChanged: context.read<HostWalletCubit>().updateIfscCode,
                          ),
                          SizedBox(height: 16.h),
                          WalletTextField(
                            label: 'Bank Name',
                            hintText: 'Enter bank name',
                            initialValue: state.bankName,
                            textCapitalizationWords: true,
                            onChanged: context.read<HostWalletCubit>().updateBankName,
                          ),
                          SizedBox(height: 16.h),
                          WalletTextField(
                            label: 'Branch Name',
                            hintText: 'Enter branch name',
                            initialValue: state.branchName,
                            textCapitalizationWords: true,
                            onChanged: context.read<HostWalletCubit>().updateBranchName,
                          ),
                          if (state.errorMessage.isNotEmpty) ...[
                            SizedBox(height: 14.h),
                            _ErrorBanner(message: state.errorMessage),
                          ],
                          SizedBox(height: 18.h),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
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
                                  onPressed: () => _submitBank(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: AppColors.white,
                                    minimumSize: Size.fromHeight(54.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
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

  void _submitBank(BuildContext context) {
    final submitted = context.read<HostWalletCubit>().addBankAccount();
    if (!submitted) {
      return;
    }

    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (rootContext.mounted) {
        HostWalletBottomSheetPresenter.showSelectBankSheet(rootContext);
      }
    });
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
