import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
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
              child: _buildAvatarImage(avatarAsset),
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

  Widget _buildAvatarImage(String path) {
    if (path.isNotEmpty) {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          width: 120.w,
          height: 120.w,
          errorBuilder: (context, error, stackTrace) => _fallbackImage(),
        );
      }
      if (path.startsWith('/uploads/')) {
        return Image.network(
          '${ApiEndpoints.baseUrl}$path',
          fit: BoxFit.cover,
          width: 120.w,
          height: 120.w,
          errorBuilder: (context, error, stackTrace) => _fallbackImage(),
        );
      }
      if (File(path).existsSync()) {
        return Image.file(
          File(path),
          fit: BoxFit.cover,
          width: 120.w,
          height: 120.w,
          errorBuilder: (context, error, stackTrace) => _fallbackImage(),
        );
      }
      if (path.startsWith('assets/')) {
        return Image.asset(
          path,
          fit: BoxFit.cover,
          width: 120.w,
          height: 120.w,
          errorBuilder: (context, error, stackTrace) => _fallbackImage(),
        );
      }
    }
    return _fallbackImage();
  }

  Widget _fallbackImage() {
    return Image.asset(
      AppAssets.femaleIcon,
      fit: BoxFit.cover,
      width: 120.w,
      height: 120.w,
    );
  }

  static const List<String> _hostAvatars = [
    'assets/host_profile_img/h1.jpeg',
    'assets/host_profile_img/h2.jpeg',
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
    'assets/host_profile_img/h17.jpeg',
    'assets/host_profile_img/h18.jpeg',
    'assets/host_profile_img/h19.jpeg',
    'assets/host_profile_img/h20.jpeg',
  ];


  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      backgroundColor: AppColors.white,
      builder: (sheetContext) {
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
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () => _pick(sheetContext, ImageSource.camera),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.all(12.r),
                        child: Column(
                          children: [
                            Icon(Icons.camera_alt_outlined, color: AppColors.primaryColor, size: 28.sp),
                            SizedBox(height: 4.h),
                            Text('Camera', style: GoogleFonts.manrope(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _pick(sheetContext, ImageSource.gallery),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.all(12.r),
                        child: Column(
                          children: [
                            Icon(Icons.photo_library_outlined, color: AppColors.primaryColor, size: 28.sp),
                            SizedBox(height: 4.h),
                            Text('Gallery', style: GoogleFonts.manrope(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Or pick a preset avatar',
                  style: GoogleFonts.manrope(
                    fontSize: 13.sp,
                    color: AppColors.subtitleText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 110.h,
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
                            Navigator.pop(sheetContext);
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pick(BuildContext context, ImageSource source) async {
    Navigator.pop(context);
    final image = await ImagePicker().pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 78,
    );
    if (image != null) onAvatarChanged(image.path);
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
                width: 70.w,
                height: 70.w,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70.w,
                  height: 70.w,
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  child: Icon(Icons.person, color: AppColors.primaryColor, size: 36.sp),
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primaryColor : AppColors.subtitleText,
            ),
          ),
        ],
      ),
    );
  }
}

