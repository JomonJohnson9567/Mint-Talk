// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? titleColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 14,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Row(
          children: [
            _SettingsIconBadge(
              icon: icon,
              iconColor: iconColor,
              bgColor: iconBgColor,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _SettingsTileInfo(
                title: title,
                subtitle: subtitle,
                titleColor: titleColor,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsIconBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _SettingsIconBadge({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46.w,
      height: 46.w,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: iconColor, size: 24.sp),
    );
  }
}

class _SettingsTileInfo extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? titleColor;

  const _SettingsTileInfo({
    required this.title,
    required this.subtitle,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: titleColor ?? AppColors.black,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.subtitleText,
          ),
        ),
      ],
    );
  }
}
