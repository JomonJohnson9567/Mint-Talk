import 'package:flutter/material.dart';

import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Soft status pill with a leading dot: Completed / Pending / Failed.
class RechargeHistoryStatusChip extends StatelessWidget {
  final String status;

  const RechargeHistoryStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _StatusChipConfig.fromStatus(status.toLowerCase());

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.cw, vertical: 3.cw),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.cw,
            height: 6.cw,
            decoration: BoxDecoration(
              color: config.color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.cw),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 10.5.csp,
              fontWeight: FontWeight.w700,
              color: config.color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChipConfig {
  final String label;
  final Color color;

  const _StatusChipConfig({required this.label, required this.color});

  factory _StatusChipConfig.fromStatus(String status) {
    if (status == 'completed' || status == 'success') {
      return const _StatusChipConfig(
        label: AppTexts.completed,
        color: AppColors.onlineIndicator,
      );
    }

    if (status == 'pending' || status == 'processing') {
      return const _StatusChipConfig(
        label: AppTexts.pending,
        color: AppColors.orange,
      );
    }

    if (status == 'failed' || status == 'error') {
      return const _StatusChipConfig(
        label: AppTexts.failed,
        color: AppColors.red,
      );
    }

    return _StatusChipConfig(
      label: status.isEmpty
          ? 'Unknown'
          : '${status[0].toUpperCase()}${status.substring(1)}',
      color: AppColors.plumMuted,
    );
  }
}
