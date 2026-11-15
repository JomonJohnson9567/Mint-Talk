import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_icon_square.dart';

/// Tinted stat tile (icon square + label + large value) on the earnings
/// ledger.
class LedgerSummaryCard extends StatelessWidget {
  final String title;
  final String valueText;
  final String? subtitle;
  final IconData icon;
  final HostIconTint tint;

  const LedgerSummaryCard({
    super.key,
    required this.title,
    required this.valueText,
    required this.icon,
    this.tint = HostIconTint.lavender,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isLavender = tint == HostIconTint.lavender;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.cw, vertical: 14.cw),
      decoration: BoxDecoration(
        color: isLavender
            ? AppColors.hostVideoTileBg
            : AppColors.hostAudioTileBg,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isLavender ? AppColors.hostVideoIconBg : AppColors.audioBtnBg,
        ),
      ),
      child: Row(
        children: [
          HostIconSquare(icon: icon, tint: tint, size: 42),
          SizedBox(width: 10.cw),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.csp,
                    color: AppColors.hostSubtitle,
                  ),
                ),
                SizedBox(height: 2.cw),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    valueText,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 22.csp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.plumDeep,
                      height: 1.2,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 1.cw),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5.csp,
                      color: AppColors.hostSubtitle,
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
