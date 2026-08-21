import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/presentation/cubit/host_analytics_cubit.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/presentation/cubit/host_analytics_state.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/presentation/widgets/host_analytics_skeleton.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/presentation/widgets/host_targets_section.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/presentation/widgets/ledger_entry_card.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/presentation/widgets/ledger_summary_card.dart';

class HostAnalytics extends StatelessWidget {
  const HostAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SafeArea(
        child: BlocBuilder<HostAnalyticsCubit, HostAnalyticsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const HostAnalyticsSkeleton();
            }

            if (state.status == HostAnalyticsStatus.failure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48.sp,
                        color: AppColors.callEndedStatus,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.errorMessage ??
                            'Failed to load earnings ledger',
                        style: GoogleFonts.manrope(
                          fontSize: 14.sp,
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: context.read<HostAnalyticsCubit>().loadAnalytics,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        child: Text(
                          'Retry',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final ledger = state.ledger!;

            return RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: context.read<HostAnalyticsCubit>().loadAnalytics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    SizedBox(height: 20.h),
                    HostTargetsSection(targets: state.targets),
                    if (state.targets.isNotEmpty) SizedBox(height: 8.h),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 1.18,
                      children: [
                        LedgerSummaryCard(
                          title: 'Gross Revenue',
                          valueText: '₹ ${ledger.summary.totalGrossInr.toStringAsFixed(0)}',
                          subtitle: '${ledger.summary.totalCalls} calls',
                          icon: Icons.payments_rounded,
                          iconColor: const Color(0xFF6B4EE0),
                          iconBgColor: const Color(0xFF6B4EE0).withAlpha(20),
                        ),
                        LedgerSummaryCard(
                          title: 'Net Revenue',
                          valueText: '₹ ${ledger.summary.totalNetInr.toStringAsFixed(0)}',
                          subtitle: '${ledger.summary.totalBilledPoints} points',
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: AppColors.onlineIndicator,
                          iconBgColor: AppColors.onlineIndicator.withAlpha(20),
                        ),
                        LedgerSummaryCard(
                          title: 'Commission',
                          valueText:
                              '₹ ${ledger.summary.totalCommissionInr.toStringAsFixed(0)}',
                          subtitle: 'Platform share',
                          icon: Icons.percent_rounded,
                          iconColor: AppColors.orange,
                          iconBgColor: AppColors.orange.withAlpha(20),
                        ),
                        LedgerSummaryCard(
                          title: 'TDS',
                          valueText: '₹ ${ledger.summary.totalTdsInr.toStringAsFixed(0)}',
                          subtitle: 'Tax deducted',
                          icon: Icons.receipt_long_rounded,
                          iconColor: AppColors.callEndedStatus,
                          iconBgColor: AppColors.callEndedStatus.withAlpha(20),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              color: AppColors.primaryColor,
                              size: 22.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Earnings Ledger',
                              style: GoogleFonts.manrope(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Page ${ledger.page}',
                          style: GoogleFonts.manrope(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.subtitleText,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ...ledger.earnings.map(
                      (earning) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: LedgerEntryCard(earning: earning),
                      ),
                    ),
                    if (state.callStats != null) ...[
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Icon(
                            Icons.analytics_rounded,
                            color: AppColors.primaryColor,
                            size: 22.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Call Statistics Summary',
                            style: GoogleFonts.manrope(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 1.18,
                        children: [
                          LedgerSummaryCard(
                            title: 'Total Call Duration',
                            valueText: '${state.callStats!.totalDurationMinutes} mins',
                            subtitle: 'Connected time',
                            icon: Icons.timer_rounded,
                            iconColor: const Color(0xFF2196F3),
                            iconBgColor: const Color(0xFF2196F3).withAlpha(20),
                          ),
                          LedgerSummaryCard(
                            title: 'Total Billed',
                            valueText: '${state.callStats!.totalBilledMinutes} mins',
                            subtitle: 'Billable time',
                            icon: Icons.access_time_filled_rounded,
                            iconColor: const Color(0xFF4CAF50),
                            iconBgColor: const Color(0xFF4CAF50).withAlpha(20),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Icon(Icons.arrow_back, color: AppColors.black, size: 20.sp),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Earnings Ledger',
                style: GoogleFonts.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Track host revenue, commissions, and billed earnings',
                style: GoogleFonts.manrope(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subtitleText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
