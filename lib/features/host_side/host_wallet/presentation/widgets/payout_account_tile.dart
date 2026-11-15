import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_wallet_entities.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/withdrawal_status_style.dart';

/// One admin-verified payout destination, showing only the masked details
/// the API supplied. Unverified or disabled accounts render greyed out and
/// can't be picked.
class PayoutAccountTile extends StatelessWidget {
  final PayoutAccountEntity account;
  final bool isSelected;
  final VoidCallback? onTap;

  const PayoutAccountTile({
    super.key,
    required this.account,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = account.isSelectable && onTap != null;
    final isUpi = account.method == PayoutMethod.upi;
    final unavailableLabel = !account.active
        ? AppTexts.payoutAccountInactive
        : AppTexts.payoutAccountPendingVerification;

    return Opacity(
      opacity: account.isSelectable ? 1 : 0.55,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.hostVideoIconBg : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.hostVideoAccent
                  : AppColors.lavenderBorder,
              width: isSelected ? 1.6 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isUpi
                    ? Icons.qr_code_2_rounded
                    : Icons.account_balance_outlined,
                color: AppColors.plumDeep,
                size: 22.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${account.label} · ${payoutMethodLabel(account.method)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.plumDeep,
                      ),
                    ),
                    if (account.maskedDetail.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        account.maskedDetail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.hostSubtitle,
                        ),
                      ),
                    ],
                    if (!account.isSelectable) ...[
                      SizedBox(height: 2.h),
                      Text(
                        unavailableLabel,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.pendingAccent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (account.isSelectable)
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.hostSubtitle,
                  size: 20.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
