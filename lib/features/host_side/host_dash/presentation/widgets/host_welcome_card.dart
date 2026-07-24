import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_cubit.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_state.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/screen/host_profile_screen.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_avatar.dart';

class HostWelcomeCard extends StatelessWidget {
  final HostProfileState profile;

  const HostWelcomeCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => _openProfile(context),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 66.w,
                      height: 66.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE7EBF3),
                          width: 1.w,
                        ),
                        color: AppColors.primaryColor.withValues(alpha: 0.12),
                      ),
                      child: HostProfileAvatar(
                        imagePath: profile.imagePath ?? '',
                        initials: profile.initials,
                        size: 64,
                      ),
                    ),
                    Positioned(
                      bottom: 2.h,
                      right: 2.w,
                      child: Container(
                        width: 16.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF18A957),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 2.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.primaryColor,
                            size: 18.sp,
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        profile.displayPhone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.subtitleText,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          profile.displayRole,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFF6E7787),
                  size: 26.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openProfile(BuildContext context) async {
    final profileCubit = context.read<HostProfileCubit>();
    await profileCubit.loadProfile();
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: profileCubit,
          child: const HostProfileScreen(),
        ),
      ),
    );
  }
}
