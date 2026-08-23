import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/domain/entities/host_earnings_ledger_entity.dart';
import 'package:mint_talk/features/shared/system_config/presentation/cubit/system_config_cubit.dart';

class LedgerEntryCard extends StatelessWidget {
  final HostEarningEntryEntity earning;

  const LedgerEntryCard({super.key, required this.earning});

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatDate(earning.createdAt);
    final typeLabel = earning.isReferral ? 'Referral' : 'Call';
    final accentColor = earning.isReferral ? AppColors.orange : AppColors.primaryColor;
    // Same billing-granularity flag CallSummaryDialog uses: earning.billedMinutes
    // holds billed seconds, not minutes, when the app is on per-second billing.
    final isPerSecondBilling =
        context.watch<SystemConfigCubit>().state.billingUnit == 'second';
    final billedUnitLabel = isPerSecondBilling ? 'Seconds' : 'Minutes';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  earning.isReferral ? Icons.card_giftcard_rounded : Icons.call_rounded,
                  size: 16.sp,
                  color: accentColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$typeLabel earning',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.subtitleText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatCurrency(earning.netEarningInr),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _InfoChip(label: 'Gross', value: _formatCurrency(earning.grossEarningInr)),
              if (earning.billedMinutes != null)
                _InfoChip(label: billedUnitLabel, value: '${earning.billedMinutes}'),
              if (earning.billedPoints != null)
                _InfoChip(label: 'Points', value: '${earning.billedPoints}'),
            ],
          ),
          if (earning.callInfo != null) ...[
            SizedBox(height: 12.h),
            Text(
              'Call: ${earning.callInfo!.callType} • ${earning.callInfo!.duration}s • ${earning.callInfo!.status}',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.subtitleText,
              ),
            ),
          ],
          if (earning.isReferral && earning.metadata != null) ...[
            SizedBox(height: 12.h),
            Text(
              'Referral payout',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.subtitleText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    final rounded = value.round();
    final text = rounded.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '₹ $text';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = monthNames[dateTime.month - 1];
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$day $month, ${hour.toString().padLeft(2, '0')}:$minute $period';
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
    );
  }
}
