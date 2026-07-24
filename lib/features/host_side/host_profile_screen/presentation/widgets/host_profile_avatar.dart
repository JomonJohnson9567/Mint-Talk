import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class HostProfileAvatar extends StatelessWidget {
  final String imagePath;
  final String initials;
  final double size;

  const HostProfileAvatar({
    super.key,
    required this.imagePath,
    required this.initials,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedPath = imagePath.trim();
    final imageProvider = _imageProvider(normalizedPath);

    return CircleAvatar(
      radius: (size / 2).r,
      backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
      backgroundImage: imageProvider,
      child: imageProvider != null
          ? null
          : Text(
              initials.isEmpty ? 'H' : initials,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: (size * 0.3).sp,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }

  ImageProvider<Object>? _imageProvider(String path) {
    if (path.isEmpty) return null;
    if (path.startsWith('assets/')) return AssetImage(path);
    final file = File(path);
    return file.existsSync() ? FileImage(file) : null;
  }
}
