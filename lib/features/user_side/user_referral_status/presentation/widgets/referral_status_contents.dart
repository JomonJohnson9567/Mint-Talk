import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/user_referral_status/presentation/cubit/referral_status_cubit.dart';
import 'package:mint_talk/features/user_side/user_referral_status/presentation/cubit/referral_status_state.dart';
import 'package:mint_talk/features/user_side/user_referral_status/presentation/widgets/referral_status_empty_state.dart';
import 'package:mint_talk/features/user_side/user_referral_status/presentation/widgets/referral_status_summary_card.dart';
import 'package:mint_talk/features/user_side/user_referral_status/presentation/widgets/referral_status_skeleton.dart';

class ReferralStatusContents extends StatelessWidget {
  const ReferralStatusContents({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReferralStatusCubit, ReferralStatusState>(
      builder: (context, state) {
        if (state.isLoading && state.referralStatus == null) {
          return const ReferralStatusSkeleton();
        }

        if (state.status == ReferralStatusLoadStatus.failure &&
            state.referralStatus == null) {
          return _FailureState(
            message: state.errorMessage ?? 'Failed to load referral status',
            onRetry: () => context.read<ReferralStatusCubit>().loadStatus(),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () => context.read<ReferralStatusCubit>().loadStatus(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.referralStatus != null) ...[
                  ReferralStatusSummaryCard(
                    referralStatus: state.referralStatus!,
                  ),
                ] else ...[
                  const ReferralStatusEmptyState(),
                ],
                SizedBox(height: 18.h),
                _HowItWorksCard(hasData: state.referralStatus != null),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FailureState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FailureState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52.sp,
              color: AppColors.red,
            ),
            SizedBox(height: 12.h),
            Text(
              'Unable to load referral status',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.subtitleText,
                height: 1.45,
              ),
            ),
            SizedBox(height: 18.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  final bool hasData;

  const _HowItWorksCard({required this.hasData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How referral rewards work',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 12.h),
          _InfoRow(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Invite friends',
            subtitle: 'Share your referral code with new users.',
          ),
          SizedBox(height: 10.h),
          _InfoRow(
            icon: Icons.emoji_events_rounded,
            title: 'Earn reward points',
            subtitle: hasData
                ? 'Track reward points and current status from the wallet API.'
                : 'Once the API returns data, rewards will appear here.',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: AppColors.subtitleText,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
