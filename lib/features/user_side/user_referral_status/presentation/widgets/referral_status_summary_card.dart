import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/user_referral_status/domain/entities/referral_status_entity.dart';
import 'referral_status_status_chip.dart';

class ReferralStatusSummaryCard extends StatelessWidget {
  final ReferralStatusEntity referralStatus;

  const ReferralStatusSummaryCard({super.key, required this.referralStatus});

  @override
  Widget build(BuildContext context) {
    final hasCode = referralStatus.hasReferralCode;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.2),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            AppTexts.referralRewards,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        ReferralStatusChip(status: referralStatus.status),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      referralStatus.rewardPoints.toString(),
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      AppTexts.referralRewardPoints,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.82),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 54.w,
                height: 54.w,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.white,
                  size: 28.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              if (referralStatus.pendingPoints != null)
                _StatPill(
                  label: AppTexts.referralPendingPoints,
                  value: referralStatus.pendingPoints.toString(),
                ),
              if (referralStatus.totalReferrals != null)
                _StatPill(
                  label: 'Total Referrals',
                  value: referralStatus.totalReferrals.toString(),
                ),
              if (hasCode) _CodePill(code: referralStatus.referralCode!),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            AppTexts.referralInvite,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.88),
              fontSize: 12.5.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _copyReferralCode(context, referralStatus),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
                elevation: 0,
              ),
              icon: Icon(hasCode ? Icons.copy_rounded : Icons.share_rounded),
              label: Text(
                hasCode
                    ? AppTexts.copyReferralCode
                    : AppTexts.shareReferralCode,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyReferralCode(
    BuildContext context,
    ReferralStatusEntity referralStatus,
  ) async {
    final text =
        referralStatus.shareMessage ?? referralStatus.referralCode?.trim();

    if (text == null || text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Referral code is not available yet.')),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Referral code copied to clipboard')),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.72),
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CodePill extends StatelessWidget {
  final String code;

  const _CodePill({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${AppTexts.referralCodeLabel}\n',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.72),
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            TextSpan(
              text: code,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
