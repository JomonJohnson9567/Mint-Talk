import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_wallet_entities.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/withdrawal_status_style.dart';

class WithdrawalHistorySection extends StatelessWidget {
  final List<HostWithdrawalEntryEntity> withdrawals;

  const WithdrawalHistorySection({super.key, required this.withdrawals});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppTexts.recentWithdrawals,
          style: TextStyle(
            fontSize: 19.csp,
            fontWeight: FontWeight.w800,
            color: AppColors.plumDeep,
          ),
        ),
        SizedBox(height: 12.cw),
        if (withdrawals.isEmpty)
          const _EmptyWithdrawals()
        else
          ...withdrawals.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 10.cw),
              child: _WithdrawalItemCard(item: item),
            ),
          ),
      ],
    );
  }
}

class _EmptyWithdrawals extends StatelessWidget {
  const _EmptyWithdrawals();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.cw, 8.cw, 16.cw, 20.cw),
      decoration: BoxDecoration(
        // Sampled from the mascot so its opaque edges blend into the card.
        color: AppColors.noWithdrawalsCard,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          Image.asset(
            AppAssets.noWithdrawalsMascot,
            width: 190.cw,
            fit: BoxFit.contain,
          ),
          Text(
            AppTexts.noWithdrawalsYet,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 20.csp,
              fontWeight: FontWeight.w800,
              color: AppColors.plumDeep,
            ),
          ),
          SizedBox(height: 4.cw),
          Text(
            AppTexts.noWithdrawalsYetDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5.csp,
              color: AppColors.hostSubtitle,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawalItemCard extends StatelessWidget {
  final HostWithdrawalEntryEntity item;

  const _WithdrawalItemCard({required this.item});

  static const _months = [
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

  /// `12 Oct, 4:05 PM`.
  static String _formatDate(DateTime time) {
    final local = time.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day} ${_months[local.month - 1]}, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final style = WithdrawalStatusStyle.of(item.status);
    final statusColor = style.color;
    final destination = [
      payoutMethodLabel(item.payoutMethod),
      if (item.maskedDestination != null) item.maskedDestination!,
      _formatDate(item.createdAt),
    ].join(' · ');
    final reason = item.reason;
    final showReason =
        reason != null &&
        (item.status == WithdrawalStatus.rejected ||
            item.status == WithdrawalStatus.failed ||
            item.status == WithdrawalStatus.reversed);

    return Container(
      padding: EdgeInsets.all(12.cw),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.profileDivider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.cw,
            height: 42.cw,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(style.icon, size: 20.csp, color: statusColor),
          ),
          SizedBox(width: 12.cw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '₹${IndianNumberFormat.format(item.amount)}',
                        style: TextStyle(
                          fontSize: 15.csp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.plumDeep,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.cw),
                    _StatusChip(label: style.label, color: statusColor),
                  ],
                ),
                SizedBox(height: 2.cw),
                Text(
                  destination,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.csp,
                    color: AppColors.hostSubtitle,
                  ),
                ),
                SizedBox(height: 4.cw),
                Text(
                  style.description,
                  style: TextStyle(
                    fontSize: 11.5.csp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                if (showReason) ...[
                  SizedBox(height: 2.cw),
                  Text(
                    reason,
                    style: TextStyle(
                      fontSize: 11.5.csp,
                      color: AppColors.plumDeep,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.cw, vertical: 5.cw),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.csp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
