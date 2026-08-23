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

class ApplySelfieUpload extends StatelessWidget {
  const ApplySelfieUpload({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApplyForHostCubit>();
    return BlocBuilder<ApplyForHostCubit, ApplyForHostState>(
      buildWhen: (p, c) =>
          p.selfiePath != c.selfiePath ||
          p.isUploadingSelfie != c.isUploadingSelfie ||
          p.fieldErrors['selfie'] != c.fieldErrors['selfie'],
      builder: (context, state) {
        final bool hasSelfie = state.selfiePath.isNotEmpty;
        final bool hasError =
            state.fieldErrors['selfie'] != null &&
            state.fieldErrors['selfie']!.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TAKE A SELFIE',
              style: GoogleFonts.manrope(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 12.h),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: hasSelfie || state.isUploadingSelfie
                        ? null
                        : () => _captureSelfie((path) {
                            cubit.selfieChanged(path);
                            cubit.uploadSelfie(path);
                          }),
                    child: Container(
                      width: 130.w,
                      height: 130.w,
                      decoration: BoxDecoration(
                        color: hasSelfie ? AppColors.white : AppColors.softBlue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: hasError
                              ? AppColors.red
                              : (hasSelfie
                                    ? AppColors.borderSoft
                                    : AppColors.grey.withAlpha(51)),
                          width: 2,
                        ),
                      ),
                      child: hasSelfie
                          ? ClipOval(
                              child: Stack(
                                children: [
                                  Image.file(
                                    File(state.selfiePath),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                  if (state.isUploadingSelfie)
                                    Container(
                                      color: AppColors.black.withAlpha(102),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.white,
                                              ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : state.isUploadingSelfie
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryColor,
                                ),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  AppIcons.camera,
                                  color: hasError
                                      ? AppColors.red
                                      : AppColors.primaryColor,
                                  size: 30.sp,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Take Selfie',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: hasError
                                        ? AppColors.red
                                        : AppColors.subtitleText,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (hasSelfie && !state.isUploadingSelfie)
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: GestureDetector(
                        onTap: () => cubit.selfieChanged(''),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
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
                ],
              ),
            ),
            if (hasError) ...[
              SizedBox(height: 8.h),
              Center(
                child: Text(
                  state.fieldErrors['selfie']!,
                  style: GoogleFonts.manrope(
                    fontSize: 12.sp,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// KYC selfies must be captured live — picking an existing photo from the
  /// gallery would defeat the identity-verification purpose, so this only
  /// ever opens the front camera.
  Future<void> _captureSelfie(Function(String) onImageCaptured) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );
    if (picked != null) {
      onImageCaptured(picked.path);
    }
  }
}
