import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_cubit.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_state.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/host_wallet_bottom_sheet_presenter.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/payout_account_tile.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/wallet_sheet_handle.dart';

/// Amount entry + choice among the host's admin-verified payout accounts.
/// No bank/UPI details are entered here — only `amount` and the chosen
/// account's `payoutMethod` are sent.
class WithdrawAmountBottomSheet extends StatelessWidget {
  final BuildContext rootContext;

  const WithdrawAmountBottomSheet({super.key, required this.rootContext});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WalletSheetHandle(),
              SizedBox(height: 18.h),
              Text(
                AppTexts.withdrawAmountTitle,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.plumDeep,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                AppTexts.withdrawAmountSubtitle,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.4,
                  color: AppColors.hostSubtitle,
                ),
              ),
              SizedBox(height: 16.h),
              const Divider(height: 1),
              SizedBox(height: 16.h),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: BlocBuilder<HostWalletCubit, HostWalletState>(
                    builder: (context, state) => _SheetBody(
                      state: state,
                      onSubmit: () => _submitWithdrawal(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitWithdrawal(BuildContext context) async {
    final submitted = await context.read<HostWalletCubit>().submitWithdrawal();
    if (!submitted || !context.mounted) return;

    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (rootContext.mounted) {
        HostWalletBottomSheetPresenter.showWithdrawalSuccessSheet(rootContext);
      }
    });
  }
}

class _SheetBody extends StatelessWidget {
  final HostWalletState state;
  final VoidCallback onSubmit;

  const _SheetBody({required this.state, required this.onSubmit});

  /// Digits with at most one dot and two decimals.
  static final _amountFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d{0,2}'),
  );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HostWalletCubit>();
    final accounts = state.payoutAccounts;
    final hasSelectable = accounts.any((account) => account.isSelectable);
    // The request carries only the method, so one account per method can
    // be "the" selected one.
    final selectedId = accounts
        .where(
          (account) =>
              account.isSelectable &&
              account.method == state.selectedPayoutMethod,
        )
        .map((account) => account.id)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(AppTexts.withdrawalAmountLabel),
        SizedBox(height: 10.h),
        TextFormField(
          initialValue: state.withdrawalAmount,
          enabled: !state.isSubmitting,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_amountFormatter],
          onChanged: cubit.updateWithdrawalAmount,
          decoration: InputDecoration(
            hintText: AppTexts.enterAmountHint,
            prefixText: '₹ ',
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            filled: true,
            fillColor: AppColors.cardWhite,
            border: _border(AppColors.lavenderBorder, 1.2),
            enabledBorder: _border(AppColors.lavenderBorder, 1.2),
            disabledBorder: _border(AppColors.lavenderBorder, 1.2),
            focusedBorder: _border(AppColors.hostVideoAccent, 1.4),
          ),
        ),
        SizedBox(height: 8.h),
        _AmountHint(state: state),
        SizedBox(height: 16.h),
        _Label(AppTexts.withdrawTo),
        SizedBox(height: 10.h),
        for (final account in accounts) ...[
          PayoutAccountTile(
            account: account,
            isSelected: account.id == selectedId,
            onTap: state.isSubmitting
                ? null
                : () => cubit.selectPayoutMethod(account.method),
          ),
          SizedBox(height: 10.h),
        ],
        if (!hasSelectable)
          const _InfoBox(message: AppTexts.withdrawBlockedNoVerifiedAccount),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.hostToggleTrack,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.lavenderBorder),
          ),
          child: Text(
            AppTexts.availableBalanceLine(
              IndianNumberFormat.format(state.availableBalance),
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.plumDeep,
            ),
          ),
        ),
        if (state.requestMessage.isNotEmpty) ...[
          SizedBox(height: 14.h),
          _ErrorBanner(message: state.requestMessage),
        ],
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(54.h),
                  side: const BorderSide(color: AppColors.lavenderBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
                child: Text(
                  AppTexts.cancel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.plumDeep,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: ElevatedButton(
                onPressed: state.canSubmit ? onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.hostToggleTrack,
                  disabledForegroundColor: AppColors.hostSubtitle,
                  minimumSize: Size.fromHeight(54.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  elevation: 0,
                ),
                child: state.isSubmitting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.primaryColor,
                        ),
                      )
                    : Text(
                        AppTexts.withdraw,
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
  }

  static OutlineInputBorder _border(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: BorderSide(color: color, width: width),
      );
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.plumDeep,
      ),
    );
  }
}

/// Live feedback under the amount field, using the backend's minimum.
class _AmountHint extends StatelessWidget {
  final HostWalletState state;

  const _AmountHint({required this.state});

  @override
  Widget build(BuildContext context) {
    final error = amountErrorMessage(state);
    final isEmpty = state.withdrawalAmount.trim().isEmpty;

    final (IconData icon, Color color, String text) = switch (error) {
      _ when isEmpty => (
        Icons.info_outline_rounded,
        AppColors.hostSubtitle,
        state.minWithdrawalAmount > 0
            ? AppTexts.amountErrorBelowMinimum(
                IndianNumberFormat.format(state.minWithdrawalAmount),
              )
            : AppTexts.amountErrorEmpty,
      ),
      null => (
        Icons.check_circle_outline_rounded,
        AppColors.green,
        AppTexts.amountValid,
      ),
      final message => (Icons.error_outline_rounded, AppColors.red, message),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.sp, color: color),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: color,
              fontWeight: isEmpty ? FontWeight.w500 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String message;

  const _InfoBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.hostAudioTileBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.audioBtnBg),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.plumDeep,
          height: 1.4,
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
