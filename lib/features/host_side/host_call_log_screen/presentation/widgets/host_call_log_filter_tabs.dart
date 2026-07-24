// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

enum HostCallFilterType { video, audio }

class HostCallLogFilterTabs extends StatelessWidget {
  final HostCallFilterType selectedFilter;
  final ValueChanged<HostCallFilterType> onFilterChanged;

  const HostCallLogFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _FilterTab(
            label: 'Video Call',
            icon: Icons.videocam,
            isSelected: selectedFilter == HostCallFilterType.video,
            onTap: () => onFilterChanged(HostCallFilterType.video),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _FilterTab(
            label: 'Audio Call',
            icon: Icons.phone,
            isSelected: selectedFilter == HostCallFilterType.audio,
            onTap: () => onFilterChanged(HostCallFilterType.audio),
          ),
        ),
      ],
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.white,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.primaryColor.withAlpha(80),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withAlpha(60),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.primaryColor,
              size: 18.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.primaryColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
