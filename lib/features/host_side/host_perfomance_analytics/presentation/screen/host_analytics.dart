import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/presentation/cubit/host_analytics_cubit.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/presentation/cubit/host_analytics_state.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/presentation/widgets/host_analytics_skeleton.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/presentation/widgets/host_leaderboard_section.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/presentation/widgets/host_targets_section.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/domain/entities/host_earnings_ledger_entity.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/presentation/widgets/ledger_entry_card.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/presentation/widgets/ledger_period_chip.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/presentation/widgets/ledger_summary_card.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_icon_square.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_mascot_banner.dart';
import 'package:mint_talk/features/shared/system_config/presentation/cubit/system_config_cubit.dart';

class HostAnalytics extends StatelessWidget {
  const HostAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: const CustomAppBar(
        title: AppTexts.earningsLedger,
        foregroundColor: AppColors.plumDeep,
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<HostAnalyticsCubit, HostAnalyticsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const HostAnalyticsSkeleton();
            }

            if (state.status == HostAnalyticsStatus.failure) {
              return _LedgerLoadFailure(
                message: state.errorMessage ?? 'Failed to load earnings ledger',
              );
            }

            return RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: context.read<HostAnalyticsCubit>().loadAnalytics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.cw, 4.cw, 16.cw, 24.cw),
                child: _LedgerBody(state: state),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LedgerBody extends StatelessWidget {
  final HostAnalyticsState state;

  const _LedgerBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final ledger = state.ledger!;
    final isRecent = state.scope == EarningsLedgerScope.recent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.hasPeriod) ...[
          LedgerPeriodChip(start: state.periodStart!, end: state.periodEnd!),
          SizedBox(height: 14.cw),
        ],
        const HostMascotBanner(
          title: AppTexts.growingTogether,
          subtitle: AppTexts.everyConversationBuildsJourney,
          mascotAsset: AppAssets.rechargeMascot,
          mascotHeight: 100,
        ),
        SizedBox(height: 16.cw),
        _StatGrid(state: state),
        if (state.leaderboard.isNotEmpty) ...[
          SizedBox(height: 22.cw),
          HostLeaderboardSection(entries: state.leaderboard),
        ],
        if (state.targets.isNotEmpty) ...[
          SizedBox(height: 22.cw),
          HostTargetsSection(targets: state.targets),
        ],
        SizedBox(height: 22.cw),
        Text(
          isRecent ? AppTexts.recentEarnings : AppTexts.earningsHistory,
          style: TextStyle(
            fontSize: 19.csp,
            fontWeight: FontWeight.w800,
            color: AppColors.plumDeep,
          ),
        ),
        SizedBox(height: 10.cw),
        _ScopeToggle(selected: state.scope),
        SizedBox(height: 12.cw),
        if (state.isLedgerLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.cw),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          )
        else if (ledger.earnings.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.cw),
            child: Text(
              isRecent ? AppTexts.noRecentEarnings : AppTexts.noEarningsHistory,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.csp,
                color: AppColors.hostSubtitle,
                height: 1.4,
              ),
            ),
          )
        else
          ...ledger.earnings.map(
            (earning) => Padding(
              padding: EdgeInsets.only(bottom: 12.cw),
              child: LedgerEntryCard(
                earning: earning,
                showRemaining: isRecent,
              ),
            ),
          ),
        SizedBox(height: 12.cw),
        const _LedgerInfoFooter(),
      ],
    );
  }
}

/// Gross / Net on the first row, Connected / Billable (when call stats are
/// available) on the second. Rows rather than a fixed-aspect grid so tiles
/// grow with the text scale instead of overflowing.
class _StatGrid extends StatelessWidget {
  final HostAnalyticsState state;

  const _StatGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final summary = state.ledger!.summary;
    final withdrawable = state.ledger!.withdrawableBalanceInr;
    final callStats = state.callStats;
    final isPerSecondBilling = context.select<SystemConfigCubit, bool>(
      (cubit) => cubit.state.isPerSecondBilling,
    );

    return Column(
      children: [
        _StatRow(
          left: LedgerSummaryCard(
            title: AppTexts.grossRevenue,
            valueText: _inr(summary.totalGrossInr),
            subtitle: '${summary.totalCalls} calls',
            icon: Icons.paid_outlined,
          ),
          right: LedgerSummaryCard(
            title: AppTexts.netEarnings,
            valueText: _inr(summary.totalNetInr),
            icon: Icons.account_balance_wallet_outlined,
            tint: HostIconTint.peach,
          ),
        ),
        if (withdrawable != null) ...[
          SizedBox(height: 12.cw),
          LedgerSummaryCard(
            title: AppTexts.availableBalance,
            valueText: '₹${IndianNumberFormat.format(withdrawable)}',
            icon: Icons.savings_outlined,
          ),
        ],
        if (callStats != null) ...[
          SizedBox(height: 12.cw),
          _StatRow(
            left: LedgerSummaryCard(
              title: AppTexts.connectedLabel,
              valueText: '${callStats.totalDurationMinutes} min',
              icon: Icons.call_outlined,
            ),
            right: LedgerSummaryCard(
              title: AppTexts.billableLabel,
              valueText:
                  '${callStats.totalBilledUnits} ${isPerSecondBilling ? 'sec' : 'min'}',
              icon: Icons.schedule_rounded,
              tint: HostIconTint.peach,
            ),
          ),
        ],
      ],
    );
  }

  static String _inr(double value) =>
      '₹${IndianNumberFormat.format(value.round())}';
}

/// Recent (unpaid) vs full-history ledger.
class _ScopeToggle extends StatelessWidget {
  final EarningsLedgerScope selected;

  const _ScopeToggle({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.cw),
      decoration: BoxDecoration(
        color: AppColors.hostToggleTrack,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.lavenderBorder),
      ),
      child: Row(
        children: [
          for (final (scope, label) in const [
            (EarningsLedgerScope.recent, AppTexts.earningsScopeRecent),
            (EarningsLedgerScope.history, AppTexts.earningsScopeHistory),
          ])
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    context.read<HostAnalyticsCubit>().selectScope(scope),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(vertical: 10.cw),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scope == selected
                        ? AppColors.primaryColor
                        : AppColors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.csp,
                      fontWeight: FontWeight.w700,
                      color: scope == selected
                          ? AppColors.white
                          : AppColors.hostSubtitle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _StatRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          SizedBox(width: 12.cw),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _LedgerInfoFooter extends StatelessWidget {
  const _LedgerInfoFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 12.cw),
      decoration: BoxDecoration(
        color: AppColors.hostToggleTrack,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_rounded, size: 18.csp, color: AppColors.hostSubtitle),
          SizedBox(width: 8.cw),
          Flexible(
            child: Text(
              AppTexts.weeklyTotalsUpdate,
              style: TextStyle(
                fontSize: 12.5.csp,
                color: AppColors.hostSubtitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerLoadFailure extends StatelessWidget {
  final String message;

  const _LedgerLoadFailure({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.cw),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.cw,
              height: 80.cw,
              decoration: const BoxDecoration(
                color: AppColors.audioBtnBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 38.csp,
                color: AppColors.audioAccent,
              ),
            ),
            SizedBox(height: 16.cw),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.csp, color: AppColors.plumMuted),
            ),
            SizedBox(height: 20.cw),
            ElevatedButton(
              onPressed: context.read<HostAnalyticsCubit>().loadAnalytics,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 28.cw,
                  vertical: 12.cw,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(
                AppTexts.retry,
                style: TextStyle(
                  fontSize: 14.csp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
