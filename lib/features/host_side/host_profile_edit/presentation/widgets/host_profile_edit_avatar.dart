import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_icons.dart';
import '../../../../../core/theme/color.dart';

class HostProfileEditAvatar extends StatelessWidget {
  final String avatarAsset;
  final Function(String) onAvatarChanged;

  const HostProfileEditAvatar({
    super.key,
    required this.avatarAsset,
    required this.onAvatarChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryColor.withAlpha(26),
                width: 4,
              ),
              color: AppColors.lightGrey,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60.w),
              child: Image.asset(
                avatarAsset.isNotEmpty ? avatarAsset : AppAssets.femaleIcon,
                fit: BoxFit.cover,
                width: 120.w,
                height: 120.w,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    AppAssets.femaleIcon,
                    fit: BoxFit.cover,
                    width: 120.w,
                    height: 120.w,
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showAvatarPicker(context),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Icon(AppIcons.edit, color: AppColors.white, size: 16.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const List<String> _hostAvatars = [
    'assets/host_profile_img/h1.jpeg',
    'assets/host_profile_img/h2.jpeg',
    'assets/host_profile_img/h3.jpeg',
    'assets/host_profile_img/h4.jpeg',
    'assets/host_profile_img/h5.jpeg',
    'assets/host_profile_img/h6.jpeg',
    'assets/host_profile_img/h7.jpeg',
    'assets/host_profile_img/h8.jpeg',
    'assets/host_profile_img/h9.jpeg',
    'assets/host_profile_img/h10.jpeg',
    'assets/host_profile_img/h11.jpeg',
    'assets/host_profile_img/h12.jpeg',
    'assets/host_profile_img/13.jpeg',
    'assets/host_profile_img/14.jpeg',
    'assets/host_profile_img/h15.jpeg',
  ];

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      backgroundColor: AppColors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose Profile Avatar',
                  style: GoogleFonts.manrope(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  height: 120.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _hostAvatars.length,
                    itemBuilder: (context, index) {
                      final assetPath = _hostAvatars[index];
                      final isSelected = avatarAsset == assetPath;

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: _AvatarOption(
                          assetPath: assetPath,
                          label: 'Pic ${index + 1}',
                          isSelected: isSelected,
                          onTap: () {
                            onAvatarChanged(assetPath);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AvatarOption extends StatelessWidget {
  final String assetPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarOption({
    required this.assetPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : Colors.transparent,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40.w),
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                width: 80.w,
                height: 80.w,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primaryColor : AppColors.subtitleText,
            ),
          ),
        ],
      ),
    );
  }
}
