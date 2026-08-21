import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/cubit/profile_info_cubit.dart';
import 'profile_avatar_skeleton.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
          buildWhen: (previous, current) =>
              previous.isLoading != current.isLoading,
          builder: (context, state) {
            if (state.isLoading) return const ProfileAvatarSkeleton();
            return Column(
              children: [
                const _UserAvatarSection(),
                SizedBox(height: 16.h),
                const _UserInfoSection(),
              ],
            );
          },
        ),
        SizedBox(height: 32.h),
        const _ApplyHostButton(),
      ],
    );
  }
}

class _UserAvatarSection extends StatelessWidget {
  const _UserAvatarSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
      builder: (context, state) {
        final name = state.fullName?.trim() ?? '';
        final initials = name.isEmpty
            ? 'U'
            : name
                  .split(RegExp(r'\s+'))
                  .where((part) => part.isNotEmpty)
                  .take(2)
                  .map((part) => part[0].toUpperCase())
                  .join();
        final imagePath = state.imagePath ?? '';
        final imageProvider = _resolveImageProvider(imagePath);

        return Stack(
          children: [
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.green.withValues(alpha: 0.2),
                  width: 12.w,
                ),
              ),
              child: CircleAvatar(
                radius: 50.r,
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
                backgroundImage: imageProvider,
                child: imageProvider != null
                    ? null
                    : Text(
                        initials,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor,
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: 15.h,
              right: 15.w,
              child: Container(
                height: 16.h,
                width: 16.h,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2.w),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  ImageProvider? _resolveImageProvider(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }
    if (trimmed.startsWith('/uploads/')) {
      return NetworkImage('${ApiEndpoints.baseUrl}$trimmed');
    }
    if (File(trimmed).existsSync()) {
      return FileImage(File(trimmed));
    }
    if (trimmed.startsWith('assets/')) {
      return AssetImage(trimmed);
    }
    return null;
  }
}

class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
      builder: (context, state) {
        final displayName = state.fullName?.trim().isNotEmpty == true
            ? state.fullName!.trim()
            : 'User';
        final displayPhone = state.phone?.trim().isNotEmpty == true
            ? state.phone!.trim()
            : 'No phone number';

        return Column(
          children: [
            Text(
              displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              displayPhone,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ApplyHostButton extends StatelessWidget {
  const _ApplyHostButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 66.h,
      decoration: BoxDecoration(
        color: AppColors.chatIcon,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.chatIcon.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            try {
              await context.read<ProfileInfoCubit>().handleApplyHostTap();
            } catch (_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Unable to continue. Please try again.'),
                  backgroundColor: AppColors.red,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                _buildButtonIcon(),
                SizedBox(width: 16.w),
                Text(
                  AppTexts.becomeAHost,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.white,
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonIcon() {
    return Container(
      height: 40.h,
      width: 40.h,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Icon(
          Icons.person_add_outlined,
          color: AppColors.white,
          size: 20.sp,
        ),
      ),
    );
  }
}
