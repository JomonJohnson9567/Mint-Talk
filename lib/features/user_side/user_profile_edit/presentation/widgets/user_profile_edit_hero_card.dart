import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Lavender card mirroring the profile header: editable avatar, a live
/// preview of the name being typed and the change-photo shortcut, with the
/// mascot faded in on the right.
class UserProfileEditHeroCard extends StatelessWidget {
  const UserProfileEditHeroCard({
    super.key,
    required this.imagePath,
    required this.fullName,
    required this.onImageChanged,
  });

  final String imagePath;
  final String fullName;
  final ValueChanged<String> onImageChanged;

  @override
  Widget build(BuildContext context) {
    void showPicker() => _PhotoSourceSheet.show(
      context,
      hasPhoto: imagePath.isNotEmpty,
      onChanged: onImageChanged,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.cw),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.videoCardBg, AppColors.cardWhite],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: 136.cw,
              child: const _FadedMascot(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.cw, 18.cw, 104.cw, 18.cw),
              child: Row(
                children: [
                  _EditableAvatar(
                    fullName: fullName,
                    imagePath: imagePath,
                    onTap: showPicker,
                  ),
                  SizedBox(width: 12.cw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fullName.trim().isEmpty
                              ? AppTexts.yourNamePlaceholder
                              : fullName.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 20.csp,
                            fontWeight: FontWeight.w800,
                            color: fullName.trim().isEmpty
                                ? AppColors.plumHint
                                : AppColors.plumDeep,
                          ),
                        ),
                        SizedBox(height: 10.cw),
                        _ChangePhotoButton(onTap: showPicker),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The mascot PNG has an opaque background, so its left edge is masked out
/// to melt into the card gradient.
class _FadedMascot extends StatelessWidget {
  const _FadedMascot();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColors.transparent, AppColors.black],
        stops: [0.0, 0.4],
      ).createShader(bounds),
      child: Image.asset(AppAssets.profileMascot, fit: BoxFit.cover),
    );
  }
}

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar({
    required this.fullName,
    required this.imagePath,
    required this.onTap,
  });

  final String fullName;
  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = fullName.trim();
    final initials = name.isEmpty
        ? 'U'
        : name
              .split(RegExp(r'\s+'))
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part[0].toUpperCase())
              .join();
    final imageProvider = _resolveImageProvider(imagePath);
    final size = 82.cw;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 3.cw),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: size / 2,
                backgroundColor: AppColors.primaryColor,
                backgroundImage: imageProvider,
                child: imageProvider != null
                    ? null
                    : Text(
                        initials,
                        style: GoogleFonts.nunito(
                          fontSize: 32.csp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),
            Positioned(
              right: -2.cw,
              bottom: 0,
              child: Container(
                width: 30.cw,
                height: 30.cw,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2.5.cw),
                ),
                child: Icon(
                  Icons.photo_camera_rounded,
                  size: 14.csp,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
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
}

class _ChangePhotoButton extends StatelessWidget {
  const _ChangePhotoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20.cw);

    return Material(
      color: AppColors.white.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: AppColors.primaryColor, width: 1.4.cw),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 6.cw),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.photo_camera_outlined,
                size: 15.csp,
                color: AppColors.plumDeep,
              ),
              SizedBox(width: 6.cw),
              Flexible(
                child: Text(
                  AppTexts.changePhoto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.csp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.plumDeep,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Camera / gallery / remove sheet, styled like the profile menu rows.
class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet({required this.hasPhoto, required this.onChanged});

  final bool hasPhoto;
  final ValueChanged<String> onChanged;

  static void show(
    BuildContext context, {
    required bool hasPhoto,
    required ValueChanged<String> onChanged,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardWhite,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.cw)),
      ),
      builder: (_) =>
          _PhotoSourceSheet(hasPhoto: hasPhoto, onChanged: onChanged),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.cw, 0, 8.cw, 12.cw),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.cw, 0, 14.cw, 8.cw),
              child: Text(
                AppTexts.profilePhoto,
                style: GoogleFonts.nunito(
                  fontSize: 18.csp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.plumDeep,
                ),
              ),
            ),
            _SheetRow(
              icon: Icons.photo_camera_rounded,
              label: AppTexts.takePhoto,
              onTap: () => _pick(context, ImageSource.camera),
            ),
            _SheetRow(
              icon: Icons.photo_library_rounded,
              label: AppTexts.chooseFromGallery,
              onTap: () => _pick(context, ImageSource.gallery),
            ),
            if (hasPhoto)
              _SheetRow(
                icon: Icons.delete_outline_rounded,
                label: AppTexts.removePhoto,
                color: AppColors.linkMagenta,
                iconColor: AppColors.linkMagenta,
                chipColor: AppColors.linkMagenta.withValues(alpha: 0.08),
                onTap: () {
                  Navigator.pop(context);
                  onChanged('');
                },
              ),
          ],
        ),
      ),
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
    if (image != null) onChanged(image.path);
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.plumDeep,
    this.iconColor = AppColors.primaryColor,
    this.chipColor = AppColors.popularCardBg,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;
  final Color chipColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.cw),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 9.cw),
        child: Row(
          children: [
            Container(
              width: 36.cw,
              height: 36.cw,
              decoration: BoxDecoration(
                color: chipColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19.csp, color: iconColor),
            ),
            SizedBox(width: 14.cw),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.csp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
