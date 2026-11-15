import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

class WalletSummaryItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String amount;

  const WalletSummaryItem({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.amount,
  });
}

/// Equal-height row of white withdrawable / approved / pending tiles.
class WalletSummaryRow extends StatelessWidget {
  final List<WalletSummaryItem> items;

  const WalletSummaryRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(width: 10.cw),
            Expanded(child: _SummaryCard(item: items[i])),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final WalletSummaryItem item;

  const _SummaryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.cw),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.cw,
            height: 38.cw,
            decoration: BoxDecoration(
              color: item.iconBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 20.csp),
          ),
          SizedBox(height: 12.cw),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5.csp, color: AppColors.hostSubtitle),
          ),
          SizedBox(height: 2.cw),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              item.amount,
              maxLines: 1,
              style: TextStyle(
                fontSize: 18.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
