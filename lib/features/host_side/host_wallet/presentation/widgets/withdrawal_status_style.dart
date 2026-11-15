import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_wallet_entities.dart';

/// Chip label, explanation line, colour and icon for each backend status.
/// `approved` is a legacy state under reconciliation — never styled as paid.
class WithdrawalStatusStyle {
  final String label;
  final String description;
  final Color color;
  final IconData icon;

  const WithdrawalStatusStyle._(
    this.label,
    this.description,
    this.color,
    this.icon,
  );

  factory WithdrawalStatusStyle.of(WithdrawalStatus status) {
    return switch (status) {
      WithdrawalStatus.pending => const WithdrawalStatusStyle._(
        AppTexts.withdrawalStatusPending,
        AppTexts.withdrawalDescPending,
        AppColors.pendingAccent,
        Icons.schedule_rounded,
      ),
      WithdrawalStatus.processing => const WithdrawalStatusStyle._(
        AppTexts.withdrawalStatusProcessing,
        AppTexts.withdrawalDescProcessing,
        AppColors.hostVideoAccent,
        Icons.sync_rounded,
      ),
      WithdrawalStatus.paid => const WithdrawalStatusStyle._(
        AppTexts.withdrawalStatusPaid,
        AppTexts.withdrawalDescPaid,
        AppColors.onlineIndicator,
        Icons.check_circle_rounded,
      ),
      WithdrawalStatus.rejected => const WithdrawalStatusStyle._(
        AppTexts.withdrawalStatusRejected,
        AppTexts.withdrawalDescRejected,
        AppColors.callEndedStatus,
        Icons.block_rounded,
      ),
      WithdrawalStatus.failed => const WithdrawalStatusStyle._(
        AppTexts.withdrawalStatusFailed,
        AppTexts.withdrawalDescFailed,
        AppColors.callEndedStatus,
        Icons.error_outline_rounded,
      ),
      WithdrawalStatus.reversed => const WithdrawalStatusStyle._(
        AppTexts.withdrawalStatusReversed,
        AppTexts.withdrawalDescReversed,
        AppColors.pendingAccent,
        Icons.undo_rounded,
      ),
      WithdrawalStatus.approved => const WithdrawalStatusStyle._(
        AppTexts.withdrawalStatusUnderReview,
        AppTexts.withdrawalDescUnderReview,
        AppColors.hostSubtitle,
        Icons.manage_search_rounded,
      ),
      WithdrawalStatus.unknown => const WithdrawalStatusStyle._(
        AppTexts.withdrawalStatusUnknown,
        AppTexts.withdrawalDescUnknown,
        AppColors.hostSubtitle,
        Icons.help_outline_rounded,
      ),
    };
  }
}

String payoutMethodLabel(String method) => method == PayoutMethod.upi
    ? AppTexts.payoutMethodUpi
    : AppTexts.payoutMethodBank;
