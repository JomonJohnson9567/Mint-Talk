import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mint_talk/core/constants/app_icons.dart';
import 'package:mint_talk/core/theme/color.dart';
import '../cubit/apply_for_host_cubit.dart';
import '../cubit/apply_for_host_state.dart';

class ApplyAadhaarUpload extends StatelessWidget {
  const ApplyAadhaarUpload({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApplyForHostCubit>();
    return BlocBuilder<ApplyForHostCubit, ApplyForHostState>(
      buildWhen: (p, c) =>
          p.aadhaarFrontPath != c.aadhaarFrontPath ||
          p.aadhaarBackPath != c.aadhaarBackPath ||
          p.isUploadingFront != c.isUploadingFront ||
          p.isUploadingBack != c.isUploadingBack ||
          p.fieldErrors['aadhaarFront'] != c.fieldErrors['aadhaarFront'] ||
          p.fieldErrors['aadhaarBack'] != c.fieldErrors['aadhaarBack'],
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UPLOAD AADHAAR CARD',
              style: GoogleFonts.manrope(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _UploadCard(
                    title: 'Front Side',
                    imagePath: state.aadhaarFrontPath,
                    isLoading: state.isUploadingFront,
                    errorText: state.fieldErrors['aadhaarFront'],
                    onTap: () => _pickImage(context, (path) {
                      cubit.aadhaarFrontChanged(path);
                      cubit.uploadAadhaarFront(path);
                    }),
                    onRemove: () => cubit.aadhaarFrontChanged(''),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _UploadCard(
                    title: 'Back Side',
                    imagePath: state.aadhaarBackPath,
                    isLoading: state.isUploadingBack,
                    errorText: state.fieldErrors['aadhaarBack'],
                    onTap: () => _pickImage(context, (path) {
                      cubit.aadhaarBackChanged(path);
                      cubit.uploadAadhaarBack(path);
                    }),
                    onRemove: () => cubit.aadhaarBackChanged(''),
                  ),
                ),
              ],
            ),
            if (state.fieldErrors['aadhaarFront'] != null) ...[
              SizedBox(height: 4.h),
              Text(
                state.fieldErrors['aadhaarFront']!,
                style: GoogleFonts.manrope(
                  fontSize: 12.sp,
                  color: AppColors.red,
                ),
              ),
            ] else if (state.fieldErrors['aadhaarBack'] != null) ...[
              SizedBox(height: 4.h),
              Text(
                state.fieldErrors['aadhaarBack']!,
                style: GoogleFonts.manrope(
                  fontSize: 12.sp,
                  color: AppColors.red,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _pickImage(BuildContext context, Function(String) onImagePicked) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: AppColors.white,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(AppIcons.camera, color: AppColors.primaryColor),
                title: Text(
                  'Take Photo',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (picked != null) {
                    onImagePicked(picked.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryColor),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (picked != null) {
                    onImagePicked(picked.path);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UploadCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isLoading;
  final String? errorText;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _UploadCard({
    required this.title,
    required this.imagePath,
    required this.isLoading,
    this.errorText,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imagePath.isNotEmpty;
    final bool hasError = errorText != null && errorText!.isNotEmpty;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: (hasImage || isLoading) ? null : onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: hasImage ? AppColors.white : AppColors.softBlue,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: hasError
                  ? AppColors.red
                  : (hasImage ? AppColors.borderSoft : AppColors.grey.withAlpha(51)),
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (hasImage) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                if (isLoading)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.black.withAlpha(102),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    ),
                  )
                else
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          AppIcons.close,
                          color: AppColors.white,
                          size: 14.sp,
                        ),
                      ),
                    ),
                  ),
              ] else ...[
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        AppIcons.camera,
                        color: hasError ? AppColors.red : AppColors.primaryColor,
                        size: 28.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: hasError ? AppColors.red : AppColors.subtitleText,
                        ),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
