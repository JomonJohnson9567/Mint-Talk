import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/theme/color.dart';

class UserProfileEditAvatar extends StatelessWidget {
  final String imagePath;
  final String fullName;
  final ValueChanged<String> onChanged;

  const UserProfileEditAvatar({
    super.key,
    required this.imagePath,
    required this.fullName,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final initials = fullName.trim().isEmpty
        ? 'U'
        : fullName
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part[0].toUpperCase())
              .join();

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.all(5.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: .18),
                  width: 8.w,
                ),
              ),
              child: CircleAvatar(
                radius: 54.r,
                backgroundColor: AppColors.primaryColor.withValues(alpha: .10),
                backgroundImage: _resolveImageProvider(imagePath),
                child: _resolveImageProvider(imagePath) == null
                    ? Text(
                        initials,
                        style: GoogleFonts.manrope(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor,
                        ),
                      )
                    : null,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 4.h,
              child: Material(
                color: AppColors.primaryColor,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _showPicker(context),
                  child: Padding(
                    padding: EdgeInsets.all(10.r),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 20.sp,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TextButton(
          onPressed: () => _showPicker(context),
          child: Text(
            'Change profile photo',
            style: GoogleFonts.manrope(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primaryColor,
                ),
                title: const Text('Take a photo'),
                onTap: () => _pick(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primaryColor,
                ),
                title: const Text('Choose from gallery'),
                onTap: () => _pick(sheetContext, ImageSource.gallery),
              ),
              if (imagePath.isNotEmpty)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.red,
                  ),
                  title: const Text('Remove photo'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onChanged('');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _resolveImageProvider(String path) {
    if (path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    if (path.startsWith('/uploads/')) {
      return NetworkImage('${ApiEndpoints.baseUrl}$path');
    }
    if (File(path).existsSync()) {
      return FileImage(File(path));
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    return null;
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
    if (image != null) onChanged(image.path);
  }
}
