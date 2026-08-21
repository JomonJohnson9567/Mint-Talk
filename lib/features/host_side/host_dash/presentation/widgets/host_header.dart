import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_cubit.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_state.dart';
import 'package:mint_talk/features/shared/notifications/presentation/widgets/notification_bell_icon.dart';

class HostHeader extends StatelessWidget {
  const HostHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Left Logo + App Name
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.logo,
                height: 32.h,
                width: 32.w,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
              SizedBox(width: 6.w),
              Text(
                'MintTalk',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NotificationBellIcon(
                onTap: () =>
                    getIt<NavigationService>().navigateTo(AppRoutes.hostNotificationsScreen),
              ),
              SizedBox(width: 10.w),
              BlocSelector<
                HostProfileCubit,
                HostProfileState,
                ({int? audioRate, int? videoRate})
              >(
                selector: (state) =>
                    (audioRate: state.audioRate, videoRate: state.videoRate),
                builder: (context, rates) {
                  return _HostRateCapsule(
                    audioRate: rates.audioRate,
                    videoRate: rates.videoRate,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HostRateCapsule extends StatelessWidget {
  final int? audioRate;
  final int? videoRate;

  const _HostRateCapsule({required this.audioRate, required this.videoRate});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
        side: BorderSide(color: const Color(0xFFE7EBF3), width: 1.w),
      ),
      elevation: 1,
      shadowColor: AppColors.black.withValues(alpha: 0.04),
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () {
          getIt<NavigationService>().navigateTo(AppRoutes.hostAnalytics);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RateStat(
                icon: Icons.call_rounded,
                value: _displayRate(audioRate),
                label: 'Audio Mins',
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                width: 1.w,
                height: 24.h,
                color: const Color(0xFFE7EBF3),
              ),
              _RateStat(
                icon: Icons.videocam_rounded,
                value: _displayRate(videoRate),
                label: 'Video Mins',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayRate(int? rate) => rate?.toString() ?? '—';
}

class _RateStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _RateStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 13.sp),
            ),
            SizedBox(width: 6.w),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.subtitleText,
          ),
        ),
      ],
    );
  }
}
