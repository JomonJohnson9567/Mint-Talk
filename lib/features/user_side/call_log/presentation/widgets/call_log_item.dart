import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/constants/app_assets.dart';

enum CallType { missed, outgoing }

class CallLogItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String time;
  final CallType type;
  final bool isVideoCall;
  final String? duration;
  final VoidCallback onTap;

  const CallLogItem({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.time,
    required this.type,
    this.isVideoCall = false,
    this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.grey.withAlpha(26)),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: const BoxDecoration(shape: BoxShape.circle),
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
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      _getCallIcon(type),
                      size: 16.sp,
                      color: _getCallColor(type),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (duration != null) ...[
                      SizedBox(width: 8.w),
                      Container(
                        width: 4.w,
                        height: 4.w,
                        decoration: const BoxDecoration(
                          color: AppColors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        duration!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(
              isVideoCall ? Icons.videocam : Icons.call,
              color: AppColors.green,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCallIcon(CallType type) {
    switch (type) {
      case CallType.missed:
        return Icons.call_missed;
      case CallType.outgoing:
        return Icons.call_made;
    }
  }

  Color _getCallColor(CallType type) {
    switch (type) {
      case CallType.missed:
        return Colors.red;
      case CallType.outgoing:
        return AppColors.green;
    }
  }
}
