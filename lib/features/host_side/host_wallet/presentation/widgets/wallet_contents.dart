import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_cubit.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_state.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/host_wallet_bottom_sheet_presenter.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/wallet_balance_card.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/wallet_hero_section.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/wallet_summary_row.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/withdraw_money_button.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/withdrawal_history_section.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/host_wallet_skeleton.dart';

class WalletContents extends StatelessWidget {
  const WalletContents({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostWalletCubit, HostWalletState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.overview != current.overview,
      builder: (context, state) {
        if (state.status == HostWalletStatus.initial ||
            state.status == HostWalletStatus.loading) {
          return const SafeArea(
            bottom: false,
            child: HostWalletSkeleton(),
          );
        }
        final summaryItems = [
          WalletSummaryItem(
            icon: Icons.account_balance_wallet_rounded,
            iconBgColor: const Color(0xFFEEEFFC),
            iconColor: const Color(0xFF4A52DA),
            label: 'Withdrawable',
            amount: '₹ ${state.availableBalance}',
          ),
          WalletSummaryItem(
            icon: Icons.upload_rounded,
            iconBgColor: const Color(0xFFE6F4FF),
            iconColor: const Color(0xFF1E88E5),
            label: 'Approved',
            amount: '₹ ${state.approvedTotal}',
          ),
          WalletSummaryItem(
            icon: Icons.access_time_rounded,
            iconBgColor: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFFF8F00),
            label: 'Pending',
            amount: '₹ ${state.pendingTotal}',
          ),
        ];

        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      const WalletHeroSection(),
                      SizedBox(height: 20.h),
                      WalletBalanceCard(
                        balance: state.availableBalance,
                        onWithdrawTap: () =>
                            HostWalletBottomSheetPresenter.showSelectBankSheet(context),
                      ),
                      SizedBox(height: 16.h),
                      WalletSummaryRow(items: summaryItems),
                      SizedBox(height: 16.h),
                      WithdrawalHistorySection(withdrawals: state.withdrawals),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: WithdrawMoneyButton(
                  onTap: state.availableBalance >= 500
                      ? () =>
                          HostWalletBottomSheetPresenter.showSelectBankSheet(context)
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
