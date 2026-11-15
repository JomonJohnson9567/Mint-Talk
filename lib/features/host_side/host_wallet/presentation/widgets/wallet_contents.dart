import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_cubit.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_state.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/host_wallet_bottom_sheet_presenter.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/host_wallet_skeleton.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/wallet_balance_card.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/wallet_summary_row.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/withdraw_money_button.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/withdrawal_history_section.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_mascot_banner.dart';

class WalletContents extends StatelessWidget {
  const WalletContents({super.key});

  static String _inr(double value) => '₹${IndianNumberFormat.format(value)}';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostWalletCubit, HostWalletState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.overview != current.overview ||
          previous.unconfirmedRequest != current.unconfirmedRequest ||
          previous.requestStatus != current.requestStatus,
      builder: (context, state) {
        if (state.status == HostWalletStatus.initial ||
            state.status == HostWalletStatus.loading) {
          return const SafeArea(bottom: false, child: HostWalletSkeleton());
        }
        if (state.overview == null) {
          return _WalletLoadError(message: state.errorMessage);
        }

        final summary = state.summary;
        final summaryItems = [
          WalletSummaryItem(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.pendingAccent,
            iconBackground: AppColors.pendingIconBg,
            label: AppTexts.pending,
            amount: _inr(summary.pendingInr),
          ),
          WalletSummaryItem(
            icon: Icons.sync_rounded,
            iconColor: AppColors.hostVideoAccent,
            iconBackground: AppColors.hostVideoIconBg,
            label: AppTexts.processing,
            amount: _inr(summary.processingInr),
          ),
          WalletSummaryItem(
            icon: Icons.check_rounded,
            iconColor: AppColors.onlineIndicator,
            iconBackground: AppColors.approvedIconBg,
            label: AppTexts.paid,
            amount: _inr(summary.paidInr),
          ),
        ];

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: context.read<HostWalletCubit>().loadWallet,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(16.cw, 4.cw, 16.cw, 24.cw),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const HostMascotBanner(
                        title: AppTexts.hostWalletHeroTitle,
                        subtitle: AppTexts.hostWalletHeroSubtitle,
                        mascotAsset: AppAssets.hostWalletMascot,
                        // Sampled from the mascot so its edges blend in.
                        backgroundColor: AppColors.hostWalletBanner,
                        mascotHeight: 120,
                      ),
                      SizedBox(height: 14.cw),
                      WalletBalanceCard(
                        balance: state.availableBalance,
                        minWithdrawalAmount: state.minWithdrawalAmount,
                      ),
                      SizedBox(height: 14.cw),
                      WalletSummaryRow(items: summaryItems),
                      SizedBox(height: 22.cw),
                      WithdrawalHistorySection(withdrawals: state.withdrawals),
                    ],
                  ),
                ),
              ),
            ),
            _WithdrawAction(state: state),
          ],
        );
      },
    );
  }
}

/// Opens the withdrawal sheet, or — while an earlier request's outcome is
/// unknown — retries that exact request instead of starting a new one.
class _WithdrawAction extends StatelessWidget {
  final HostWalletState state;

  const _WithdrawAction({required this.state});

  @override
  Widget build(BuildContext context) {
    final block = state.withdrawalBlock;
    final isRetry = block == WithdrawalBlock.unconfirmedRequest;

    VoidCallback? onTap;
    if (isRetry) {
      onTap = () => _retry(context);
    } else if (block == null) {
      onTap = () =>
          HostWalletBottomSheetPresenter.showWithdrawAmountSheet(context);
    }

    return WithdrawMoneyButton(
      label: isRetry ? AppTexts.retryWithdrawal : AppTexts.withdrawMoney,
      isBusy: isRetry && state.isSubmitting,
      notice: withdrawalBlockMessage(state),
      onTap: onTap,
    );
  }

  Future<void> _retry(BuildContext context) async {
    final cubit = context.read<HostWalletCubit>();
    final submitted = await cubit.retryUnconfirmedWithdrawal();
    if (!context.mounted) return;
    if (submitted) {
      HostWalletBottomSheetPresenter.showWithdrawalSuccessSheet(context);
    } else if (cubit.state.requestMessage.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(cubit.state.requestMessage)));
    }
  }
}

class _WalletLoadError extends StatelessWidget {
  final String message;

  const _WalletLoadError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.cw),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppTexts.walletLoadFailed,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
            if (message.isNotEmpty) ...[
              SizedBox(height: 6.cw),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.csp,
                  color: AppColors.hostSubtitle,
                ),
              ),
            ],
            SizedBox(height: 16.cw),
            ElevatedButton(
              onPressed: context.read<HostWalletCubit>().loadWallet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.white,
              ),
              child: const Text(AppTexts.retry),
            ),
          ],
        ),
      ),
    );
  }
}
