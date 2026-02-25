import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';

class HostProfileHeader extends StatelessWidget {
  final String name;
  final bool isOnline;
  final String imageUrl;

  const HostProfileHeader({
    super.key,
    required this.name,
    required this.isOnline,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120.w,
          height: 120.w,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          foregroundDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryColor.withAlpha(51),
              width: 4.w,
            ),
          ),
          child: ClipOval(
            child: imageUrl.isNotEmpty
                ? (imageUrl.startsWith('http')
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              AppAssets.femaleIcon,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(imageUrl, fit: BoxFit.cover))
                : Image.asset(AppAssets.femaleIcon, fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          name,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          isOnline ? AppTexts.online : AppTexts.offline,
          style: TextStyle(
            fontSize: 14.sp,
            color: isOnline ? AppColors.green : AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
