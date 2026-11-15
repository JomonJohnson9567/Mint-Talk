import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import '../cubit/apply_for_host_cubit.dart';
import '../cubit/apply_for_host_state.dart';

/// Live selfie capture for KYC: the capture circle on the left and short
/// tips on the right.
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
        final errorText = state.fieldErrors['selfie'];
        final hasError = errorText != null && errorText.isNotEmpty;

        void capture() => _captureSelfie((path) {
          cubit.selfieChanged(path);
          cubit.uploadSelfie(path);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SelfieCircle(
                  selfiePath: state.selfiePath,
                  isUploading: state.isUploadingSelfie,
                  hasError: hasError,
                  onCapture: state.isUploadingSelfie ? null : capture,
                ),
                SizedBox(width: 16.cw),
                const Expanded(child: _SelfieTips()),
              ],
            ),
            if (hasError) ...[
              SizedBox(height: 10.cw),
              Text(
                errorText,
                style: TextStyle(fontSize: 12.csp, color: Colors.red.shade700),
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

class _SelfieCircle extends StatelessWidget {
  const _SelfieCircle({
    required this.selfiePath,
    required this.isUploading,
    required this.hasError,
    required this.onCapture,
  });

  final String selfiePath;
  final bool isUploading;
  final bool hasError;

  /// Null while an upload is in flight. Tapping a captured selfie retakes it.
  final VoidCallback? onCapture;

  @override
  Widget build(BuildContext context) {
    final hasSelfie = selfiePath.isNotEmpty;
    final size = 110.cw;
    final ringColor = hasError
        ? Colors.red.shade700
        : (hasSelfie ? AppColors.white : AppColors.lavenderBorder);

    return GestureDetector(
      onTap: onCapture,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.popularCardBg,
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 2.5.cw),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: hasSelfie
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(File(selfiePath), fit: BoxFit.cover),
                          if (isUploading)
                            ColoredBox(
                              color: AppColors.plumDeep.withValues(alpha: 0.45),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                        ],
                      )
                    : isUploading
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primaryColor,
                        ),
                      )
                    : _EmptyPrompt(hasError: hasError),
              ),
            ),
            if (hasSelfie && !isUploading)
              Positioned(
                right: 0,
                bottom: 2.cw,
                child: Container(
                  width: 32.cw,
                  height: 32.cw,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2.5.cw),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 16.csp,
                    color: AppColors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPrompt extends StatelessWidget {
  const _EmptyPrompt({required this.hasError});

  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final color = hasError ? Colors.red.shade700 : AppColors.primaryColor;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40.cw,
          height: 40.cw,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.photo_camera_rounded, size: 20.csp, color: color),
        ),
        SizedBox(height: 6.cw),
        Text(
          AppTexts.tapToCapture,
          style: TextStyle(
            fontSize: 11.csp,
            fontWeight: FontWeight.w700,
            color: hasError ? color : AppColors.plumMuted,
          ),
        ),
      ],
    );
  }
}

class _SelfieTips extends StatelessWidget {
  const _SelfieTips();

  static const _tips = [
    AppTexts.selfieTipLighting,
    AppTexts.selfieTipFace,
    AppTexts.selfieTipFilters,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.takeLiveSelfie,
          style: GoogleFonts.nunito(
            fontSize: 16.csp,
            fontWeight: FontWeight.w800,
            color: AppColors.plumDeep,
          ),
        ),
        SizedBox(height: 8.cw),
        for (final tip in _tips)
          Padding(
            padding: EdgeInsets.only(bottom: 6.cw),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 15.csp,
                  color: AppColors.primaryColor,
                ),
                SizedBox(width: 6.cw),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 12.5.csp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.plumMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
