import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';

class ActionButtonsSection extends StatelessWidget {
  const ActionButtonsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 15.h),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withAlpha(77),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTexts.makeYourCall,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.videocallOnlineScreen,
                      );
                    },
                    child: _CallCard(
                      icon: Icons.video_call,
                      title: AppTexts.videoCall,
                      subtitle: '1500 coins/min',
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.audioCallOnlineScreen,
                      );
                    },
                    child: _CallCard(
                      icon: Icons.call,
                      title: AppTexts.audioCall,
                      subtitle: '500 coins/min',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CallCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CallCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.white.withAlpha(51)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.white.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.white, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9.sp,
              color: AppColors.white.withAlpha(179),
            ),
          ),
        ],
      ),
    );
  }
}
