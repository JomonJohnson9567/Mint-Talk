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
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(15.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.hostProfileScreen,
                arguments: user,
              );
            },
            child: ClipOval(
              child: user.imageUrl.isNotEmpty
                  ? (user.imageUrl.startsWith('http')
                        ? Image.network(
                            user.imageUrl,
                            width: 70.w,
                            height: 70.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderAvatar(),
                          )
                        : Image.asset(
                            user.imageUrl,
                            width: 70.w,
                            height: 70.h,
                            fit: BoxFit.cover,
                          ))
                  : _buildPlaceholderAvatar(),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            user.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 5.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: user.status == UserStatus.online
                      ? AppColors.green
                      : user.status == UserStatus.offline
                      ? AppColors.favIcon
                      : AppColors.termsIcon,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                user.status == UserStatus.online
                    ? AppTexts.online
                    : user.status == UserStatus.offline
                    ? AppTexts.offline
                    : AppTexts.onCall,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: user.status == UserStatus.online
                      ? AppColors.green
                      : user.status == UserStatus.offline
                      ? AppColors.red
                      : AppColors.onCall,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: ElevatedButton(
              onPressed: () {
                if (user.status == UserStatus.online) {
                  Navigator.pushNamed(context, AppRoutes.callScreen);
                } else {
                  context.read<HomeCubit>().notifyUser(user);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: user.status == UserStatus.online
                    ? AppColors.primaryColor.withValues(alpha: 0.2)
                    : user.status == UserStatus.offline
                    ? AppColors.favIcon.withValues(alpha: 0.2)
                    : AppColors.termsIcon.withValues(alpha: 0.2),
                foregroundColor: user.status == UserStatus.online
                    ? AppColors.primaryColor
                    : user.status == UserStatus.offline
                    ? AppColors.favIcon
                    : AppColors.termsIcon.withValues(alpha: 0.8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
              child: Text(
                user.status == UserStatus.online
                    ? AppTexts.callNow
                    : AppTexts.notifyMe,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 70.w,
      height: 70.h,
      color: AppColors.lightGrey,
      child: Image.asset(AppAssets.femaleIcon, fit: BoxFit.cover),
    );
  }
}
