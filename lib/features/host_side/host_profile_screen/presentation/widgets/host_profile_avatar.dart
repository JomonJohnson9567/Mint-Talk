import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
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
    final fallbackWidget = Text(
      initials.isEmpty ? 'H' : initials,
      style: TextStyle(
        color: AppColors.primaryColor,
        fontSize: (size * 0.3).sp,
        fontWeight: FontWeight.w800,
      ),
    );

    Widget? avatarChild;
    if (normalizedPath.isNotEmpty) {
      if (normalizedPath.startsWith('http://') ||
          normalizedPath.startsWith('https://')) {
        avatarChild = Image.network(
          normalizedPath,
          fit: BoxFit.cover,
          width: size.w,
          height: size.w,
          errorBuilder: (context, error, stackTrace) =>
              Center(child: fallbackWidget),
        );
      } else if (normalizedPath.startsWith('/uploads/')) {
        avatarChild = Image.network(
          '${ApiEndpoints.baseUrl}$normalizedPath',
          fit: BoxFit.cover,
          width: size.w,
          height: size.w,
          errorBuilder: (context, error, stackTrace) =>
              Center(child: fallbackWidget),
        );
      } else if (normalizedPath.startsWith('assets/')) {
        avatarChild = Image.asset(
          normalizedPath,
          fit: BoxFit.cover,
          width: size.w,
          height: size.w,
          errorBuilder: (context, error, stackTrace) =>
              Center(child: fallbackWidget),
        );
      } else if (File(normalizedPath).existsSync()) {
        avatarChild = Image.file(
          File(normalizedPath),
          fit: BoxFit.cover,
          width: size.w,
          height: size.w,
          errorBuilder: (context, error, stackTrace) =>
              Center(child: fallbackWidget),
        );
      }
    }

    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryColor.withValues(alpha: 0.12),
      ),
      child: ClipOval(
        child: avatarChild ?? Center(child: fallbackWidget),
      ),
    );
  }
}

