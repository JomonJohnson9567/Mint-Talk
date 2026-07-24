// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_state.dart';

class HostProfileInfoSection extends StatelessWidget {
  final HostProfileState profile;
  final VoidCallback onEdit;

  const HostProfileInfoSection({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final fields = [
      _InfoField(
        icon: Icons.person_outline_rounded,
        label: 'Full Name',
        value: profile.displayName,
      ),
      _InfoField(
        icon: Icons.phone_android_rounded,
        label: 'Mobile Number',
        value: profile.displayPhone,
      ),
      _InfoField(
        icon: Icons.badge_outlined,
        label: 'Account ID',
        value: profile.displayUserId,
      ),
      _InfoField(
        icon: Icons.cake_outlined,
        label: 'Date of Birth',
        value: profile.displayDob,
      ),
      _InfoField(
        icon: Icons.wc_rounded,
        label: 'Gender',
        value: profile.displayGender,
      ),
    ];

    return Container(
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
      child: Column(
        children: [
          ...List.generate(fields.length, (index) {
            final field = fields[index];
            return Column(
              children: [
                _InfoTile(field: field),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderSoft,
                  indent: 16.w,
                  endIndent: 16.w,
                ),
              ],
            );
          }),
          _EditProfileTile(onTap: onEdit),
        ],
      ),
    );
  }
}

class _EditProfileTile extends StatelessWidget {
  final VoidCallback onTap;

  const _EditProfileTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primaryColor,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final _InfoField field;

  const _InfoTile({required this.field});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(field.icon, color: AppColors.primaryColor, size: 18.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.subtitleText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  field.value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14.sp,
            color: AppColors.subtitleText,
          ),
        ],
      ),
    );
  }
}

class _InfoField {
  final IconData icon;
  final String label;
  final String value;

  const _InfoField({
    required this.icon,
    required this.label,
    required this.value,
  });
}
