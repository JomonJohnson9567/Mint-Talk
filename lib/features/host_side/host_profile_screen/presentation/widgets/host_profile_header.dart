import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_state.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_avatar.dart';

class HostProfileHeader extends StatelessWidget {
  final HostProfileState profile;

  const HostProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileBannerWithAvatar(profile: profile),
        SizedBox(height: 28.h),
        const _VerifiedHostBadge(),
        SizedBox(height: 8.h),
        Text(
          profile.displayName,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.h),
        _ProfileSubtitle(profile: profile),
        SizedBox(height: 16.h),
      ],
    );
  }
}

class _ProfileBannerWithAvatar extends StatelessWidget {
  final HostProfileState profile;

  const _ProfileBannerWithAvatar({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        // Banner
        Container(
          height: 100.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withAlpha(40),
                AppColors.softBlue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        // Avatar
        Positioned(
          bottom: -34.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 88.w,
                height: 88.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: HostProfileAvatar(
                  imagePath: profile.imagePath ?? '',
                  initials: profile.initials,
                  size: 82,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 26.w,
                  height: 26.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: AppColors.white,
                    size: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerifiedHostBadge extends StatelessWidget {
  const _VerifiedHostBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: AppColors.white, size: 13.sp),
          SizedBox(width: 4.w),
          Text(
            'Verified Host',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSubtitle extends StatelessWidget {
  final HostProfileState profile;

  const _ProfileSubtitle({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.phone_android_rounded,
          size: 16.sp,
          color: AppColors.subtitleText,
        ),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            profile.displayPhone,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.subtitleText,
            ),
          ),
        ),
      ],
    );
  }
}
