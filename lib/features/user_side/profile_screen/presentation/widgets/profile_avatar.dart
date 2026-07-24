import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/cubit/profile_info_cubit.dart';
import 'package:mint_talk/features/user_side/apply_for_host/data/datasources/host_application_local_datasource.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _UserAvatarSection(),
        SizedBox(height: 16.h),
        const _UserInfoSection(),
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
        final imageFile = imagePath.isNotEmpty ? File(imagePath) : null;
        final hasImage = imageFile?.existsSync() == true;

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
                backgroundImage: hasImage ? FileImage(imageFile!) : null,
                child: hasImage
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
            final preferences = getIt<HostApplicationLocalDataSource>();
            try {
              if (await preferences.hasSubmittedApplication()) {
                getIt<NavigationService>().navigateTo(
                  AppRoutes.hostApplicationStatus,
                );
                return;
              }

              var accepted = await preferences.hasAcceptedTerms();
              if (!accepted) {
                accepted =
                    await getIt<NavigationService>().navigateTo(
                      AppRoutes.termsAndConditionsForHost,
                    ) ==
                    true;
              }
              if (accepted) {
                getIt<NavigationService>().navigateTo(AppRoutes.applyForHost);
              }
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
