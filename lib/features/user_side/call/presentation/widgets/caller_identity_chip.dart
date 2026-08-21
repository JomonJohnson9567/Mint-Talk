import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';

/// Top-left overlay showing who the current participant is talking to —
/// their name, avatar (falls back to a default asset when unavailable),
/// and the live call duration once the call is active.
class CallerIdentityChip extends StatelessWidget {
  final String name;
  final String? avatarPath;

  const CallerIdentityChip({super.key, required this.name, this.avatarPath});

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final resolvedAvatar = (avatarPath?.isNotEmpty ?? false)
        ? avatarPath!
        : AppAssets.maleIcon;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12.r,
            backgroundColor: AppColors.lightGrey,
            backgroundImage: resolvedAvatar.startsWith('http')
                ? NetworkImage(resolvedAvatar) as ImageProvider
                : AssetImage(resolvedAvatar),
          ),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              BlocBuilder<CallScreenCubit, CallScreenState>(
                buildWhen: (previous, current) =>
                    previous.durationSeconds != current.durationSeconds ||
                    previous.status != current.status,
                builder: (context, state) {
                  if (state.status != CallScreenStatus.active) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    _formatDuration(state.durationSeconds),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
