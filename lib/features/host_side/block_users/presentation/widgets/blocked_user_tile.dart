// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';

enum BlockedUserTileAction { unblock, report }

class BlockedUserTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String blockedReason;
  final VoidCallback onUnblockTap;
  final VoidCallback onReportTap;

  const BlockedUserTile({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.blockedReason,
    required this.onUnblockTap,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.red.withAlpha(40)),
      ),
      child: Row(
        children: [
          _BlockedAvatar(imageUrl: imageUrl),
          SizedBox(width: 14.w),
          Expanded(
            child: _BlockedInfo(
              name: name,
              blockedReason: blockedReason,
            ),
          ),
          SizedBox(width: 10.w),
          _ActionMenu(
            onUnblockTap: onUnblockTap,
            onReportTap: onReportTap,
          ),
        ],
      ),
    );
  }
}

class _BlockedAvatar extends StatelessWidget {
  final String imageUrl;

  const _BlockedAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.red.withAlpha(70), width: 2),
          ),
          child: ClipOval(
            child: imageUrl.isNotEmpty && imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) => Image.asset(
                      AppAssets.femaleIcon,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(AppAssets.femaleIcon, fit: BoxFit.cover),
          ),
        ),
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

class _BlockedInfo extends StatelessWidget {
  final String name;
  final String blockedReason;

  const _BlockedInfo({
    required this.name,
    required this.blockedReason,
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
                  color: AppColors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.red.withAlpha(18),
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
        ),
        SizedBox(height: 5.h),
        Text(
          blockedReason,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.subtitleText,
            fontWeight: FontWeight.w400,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final VoidCallback onUnblockTap;
  final VoidCallback onReportTap;

  const _ActionMenu({
    required this.onUnblockTap,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<BlockedUserTileAction>(
      tooltip: 'Blocked user options',
      onSelected: (action) {
        switch (action) {
          case BlockedUserTileAction.unblock:
            onUnblockTap();
            break;
          case BlockedUserTileAction.report:
            onReportTap();
            break;
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: BlockedUserTileAction.unblock,
          child: Row(
            children: [
              Icon(Icons.lock_open_rounded, size: 18.sp, color: AppColors.primaryColor),
              SizedBox(width: 10.w),
              const Text('Unblock'),
            ],
          ),
        ),
        PopupMenuItem(
          value: BlockedUserTileAction.report,
          child: Row(
            children: [
              Icon(Icons.flag_rounded, size: 18.sp, color: AppColors.favIcon),
              SizedBox(width: 10.w),
              const Text('Report'),
            ],
          ),
        ),
      ],
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.softBlue,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          color: AppColors.primaryColor,
          size: 22.sp,
        ),
      ),
    );
  }
}
