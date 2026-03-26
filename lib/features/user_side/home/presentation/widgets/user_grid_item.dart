// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/home/presentation/bloc/home_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/home_user_entity.dart';

class UserGridItem extends StatelessWidget {
  final HomeUserEntity user;

  const UserGridItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.hostProfileScreen,
                      arguments: user,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: user.status == UserStatus.online
                            ? AppColors.green
                            : AppColors.transparent,
                        width: 2.w,
                      ),
                    ),
                    padding: EdgeInsets.all(2.w),
                    child: ClipOval(
                      child: user.imageUrl.isNotEmpty
                          ? (user.imageUrl.startsWith('http')
                                ? Image.network(
                                    user.imageUrl,
                                    width: 60.w,
                                    height: 60.w,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildPlaceholderAvatar(60.w),
                                  )
                                : Image.asset(
                                    user.imageUrl,
                                    width: 60.w,
                                    height: 60.w,
                                    fit: BoxFit.cover,
                                  ))
                          : _buildPlaceholderAvatar(60.w),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: user.status == UserStatus.online
                            ? AppColors.green
                            : user.status == UserStatus.offline
                            ? AppColors.favIcon
                            : AppColors.termsIcon,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      user.status == UserStatus.online
                          ? AppTexts.online
                          : user.status == UserStatus.offline
                          ? AppTexts.offline
                          : AppTexts.onCall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: user.status == UserStatus.online
                            ? AppColors.green
                            : user.status == UserStatus.offline
                            ? AppColors.favIcon
                            : AppColors.termsIcon,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          SizedBox(
            width: double.infinity,
            height: 32.h,
            child: ElevatedButton(
              onPressed: () {
                if (user.status == UserStatus.online) {
                  Navigator.pushNamed(context, AppRoutes.callScreen);
                } else {
                  context.read<HomeCubit>().notifyUser(user);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: user.status == UserStatus.online
                    ? AppColors.primaryColor
                    : AppColors.white,
                foregroundColor: user.status == UserStatus.online
                    ? AppColors.white
                    : AppColors.primaryColor,
                side: user.status != UserStatus.online
                    ? BorderSide(color: AppColors.primaryColor, width: 1.w)
                    : null,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                user.status == UserStatus.online
                    ? AppTexts.callNow
                    : AppTexts.notifyMe,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar([double? size]) {
    return Container(
      width: size ?? 70.w,
      height: size ?? 70.h,
      color: AppColors.lightGrey,
      child: Image.asset(AppAssets.femaleIcon, fit: BoxFit.cover),
    );
  }
}
