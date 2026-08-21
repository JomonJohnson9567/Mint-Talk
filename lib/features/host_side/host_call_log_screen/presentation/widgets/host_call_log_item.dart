// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';

class HostCallLogItem extends StatelessWidget {
  final String userId;
  final String name;
  final String imageUrl;
  final String duration;
  final bool isVideoCall;
  final bool isBlocked;
  final VoidCallback onBlockTap;
  final VoidCallback onMessageTap;

  const HostCallLogItem({
    super.key,
    required this.userId,
    required this.name,
    required this.imageUrl,
    required this.duration,
    this.isVideoCall = true,
    this.isBlocked = false,
    required this.onBlockTap,
    required this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isBlocked
            ? AppColors.callBackground.withAlpha(120)
            : AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isBlocked
              ? AppColors.red.withAlpha(60)
              : AppColors.borderSoft,
        ),
      ),
      child: Row(
        children: [
          _CallLogAvatar(imageUrl: imageUrl, isBlocked: isBlocked),
          SizedBox(width: 14.w),
          Expanded(
            child: _CallLogInfo(
              name: name,
              isVideoCall: isVideoCall,
              isBlocked: isBlocked,
            ),
          ),
          _CallLogDuration(duration: duration),
          SizedBox(width: 8.w),
          _MessageIconButton(onTap: onMessageTap),
          SizedBox(width: 8.w),
          _BlockIconButton(isBlocked: isBlocked, onTap: onBlockTap),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _CallLogAvatar extends StatelessWidget {
  final String imageUrl;
  final bool isBlocked;

  const _CallLogAvatar({required this.imageUrl, required this.isBlocked});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isBlocked
                ? Border.all(color: AppColors.red.withAlpha(100), width: 2)
                : null,
          ),
          child: ClipOval(
            child: ColorFiltered(
              colorFilter: isBlocked
                  ? const ColorFilter.matrix(<double>[
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0,      0,      0,      1, 0,
                    ])
                  : const ColorFilter.mode(
                      Colors.transparent, BlendMode.multiply),
              child: imageUrl.isNotEmpty && imageUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Image.asset(
                        AppAssets.femaleIcon,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(AppAssets.femaleIcon, fit: BoxFit.cover),
            ),
          ),
        ),
        if (isBlocked)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
              child: Icon(Icons.block, color: AppColors.white, size: 10.sp),
            ),
          ),
      ],
    );
  }
}

class _CallLogInfo extends StatelessWidget {
  final String name;
  final bool isVideoCall;
  final bool isBlocked;

  const _CallLogInfo({
    required this.name,
    required this.isVideoCall,
    required this.isBlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: isBlocked ? AppColors.subtitleText : AppColors.black,
                  decoration:
                      isBlocked ? TextDecoration.lineThrough : TextDecoration.none,
                  decorationColor: AppColors.subtitleText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isBlocked) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.red.withAlpha(20),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.red.withAlpha(60)),
                ),
                child: Text(
                  'Blocked',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(
              isVideoCall ? Icons.videocam : Icons.phone,
              color: isBlocked ? AppColors.subtitleText : AppColors.primaryColor,
              size: 15.sp,
            ),
            SizedBox(width: 5.w),
            Text(
              isVideoCall ? 'Video Call' : 'Audio Call',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.subtitleText,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CallLogDuration extends StatelessWidget {
  final String duration;

  const _CallLogDuration({required this.duration});

  @override
  Widget build(BuildContext context) {
    return Text(
      duration,
      style: TextStyle(
        fontSize: 12.sp,
        color: AppColors.subtitleText,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _MessageIconButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MessageIconButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Message user',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.softBlue,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            color: AppColors.primaryColor,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}

class _BlockIconButton extends StatelessWidget {
  final bool isBlocked;
  final VoidCallback onTap;

  const _BlockIconButton({required this.isBlocked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isBlocked ? 'Unblock user' : 'Block user',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: isBlocked
                ? AppColors.red.withAlpha(20)
                : AppColors.softBlue,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isBlocked
                  ? AppColors.red.withAlpha(80)
                  : AppColors.borderSoft,
            ),
          ),
          child: Icon(
            Icons.block_rounded,
            color: isBlocked ? AppColors.red : AppColors.primaryColor,
            size: 22.sp,
          ),
        ),
      ),
    );
  }
}
