import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Lavender "This week · 26 Oct – 1 Nov" pill above the ledger banner.
class LedgerPeriodChip extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final VoidCallback? onTap;

  const LedgerPeriodChip({
    super.key,
    required this.start,
    required this.end,
    this.onTap,
  });

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

  String get _label {
    String dayMonth(DateTime d) => '${d.day} ${_months[d.month - 1]}';
    final today = DateUtils.dateOnly(DateTime.now());
    final isThisWeek =
        !today.isBefore(DateUtils.dateOnly(start)) &&
        !today.isAfter(DateUtils.dateOnly(end));
    final range = '${dayMonth(start)} – ${dayMonth(end)}';
    return isThisWeek ? 'This week · $range' : range;
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24.cw);

    return Center(
      child: Material(
        color: AppColors.hostToggleTrack,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: 16.cw, vertical: 10.cw),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: AppColors.lavenderBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 20.csp,
                  color: AppColors.hostVideoAccent,
                ),
                SizedBox(width: 10.cw),
                Text(
                  _label,
                  style: TextStyle(
                    fontSize: 14.csp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.plumDeep,
                  ),
                ),
                if (onTap != null) ...[
                  SizedBox(width: 8.cw),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22.csp,
                    color: AppColors.plumDeep,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
