import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';
import '../../domain/entities/call_session_entity.dart';
import '../bloc/call_summary_cubit.dart';
import '../bloc/call_summary_state.dart';

class CallSummaryDialog extends StatelessWidget {
  final CallSessionEntity session;
  final bool isHost;

  const CallSummaryDialog({
    super.key,
    required this.session,
    required this.isHost,
  });

  static void show(BuildContext context, CallSessionEntity session, bool isHost) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => CallSummaryDialog(
        session: session,
        isHost: isHost,
      ),
    );
  }

  Widget _buildSkeletonBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonBox(
          width: 64.w,
          height: 64.w,
          shape: BoxShape.circle,
        ),
        SizedBox(height: 18.h),
        if (!isHost) ...[
          SkeletonBox(
            width: 120.w,
            height: 24.h,
            borderRadius: BorderRadius.circular(20.r),
          ),
          SizedBox(height: 12.h),
        ],
        SkeletonBox(
          width: 180.w,
          height: 20.h,
          borderRadius: BorderRadius.circular(4.r),
        ),
        SizedBox(height: 12.h),
        SkeletonBox(
          width: 240.w,
          height: 12.h,
          borderRadius: BorderRadius.circular(3.r),
        ),
        SizedBox(height: 6.h),
        SkeletonBox(
          width: 160.w,
          height: 12.h,
          borderRadius: BorderRadius.circular(3.r),
        ),
        SizedBox(height: 22.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SkeletonBox(
                height: 52.h,
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: SkeletonBox(
                height: 52.h,
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SkeletonBox(
          width: double.infinity,
          height: 48.h,
          borderRadius: BorderRadius.circular(14.r),
        ),
        SizedBox(height: 24.h),
        SkeletonBox(
          width: double.infinity,
          height: 48.h,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ],
    );
  }

  Widget _buildErrorBody(BuildContext context, String error) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.error_outline_rounded, color: AppColors.red, size: 36.sp),
        ),
        SizedBox(height: 18.h),
        Text(
          'Failed to load details',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          error,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.subtitleText,
            height: 1.45,
          ),
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (!isHost) {
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Close',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CallSummaryCubit(
        session: session,
        isHost: isHost,
      ),
      child: BlocBuilder<CallSummaryCubit, CallSummaryState>(
        builder: (context, state) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: SingleChildScrollView(
              child: Container(
                width: 320.w,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: AppColors.borderSoft, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: state.isLoading
                    ? _buildSkeletonBody()
                    : state.errorMessage != null
                        ? _buildErrorBody(context, state.errorMessage!)
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeaderBadge(state),
                              SizedBox(height: 18.h),
                              if (!state.isHost) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: state.talkLevelColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: state.talkLevelColor.withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.stars_rounded,
                                        size: 16.sp,
                                        color: state.talkLevelColor,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        state.talkLevel,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w700,
                                          color: state.talkLevelColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12.h),
                              ],
                              Text(
                                state.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.black,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Text(
                                  state.motivationMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.subtitleText,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                              SizedBox(height: 22.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _StatCard(
                                      icon: Icons.timer_outlined,
                                      iconColor: AppColors.primaryColor,
                                      label: 'Duration',
                                      value: state.durationText,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: _StatCard(
                                      icon: Icons.confirmation_number_outlined,
                                      iconColor: Colors.teal,
                                      label: 'Billed Min',
                                      value: '${state.billedMinutes} min',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              _StatCard(
                                icon: Icons.monetization_on_rounded,
                                iconColor: AppColors.ratingGold,
                                label: state.pointsLabel,
                                value: '${state.pointsValue} pts',
                                isWide: true,
                              ),
                              SizedBox(height: 24.h),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    padding: EdgeInsets.symmetric(vertical: 14.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    if (!isHost) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Text(
                                    'Done',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderBadge(CallSummaryState state) {
    if (state.isHost) {
      return Container(
        height: 64.w,
        width: 64.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.ratingGold.withValues(alpha: 0.25),
              AppColors.ratingGold.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.ratingGold.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.emoji_events_rounded,
          color: AppColors.ratingGold,
          size: 32.sp,
        ),
      );
    } else {
      return Container(
        height: 64.w,
        width: 64.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              state.talkLevelColor.withValues(alpha: 0.25),
              state.talkLevelColor.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: state.talkLevelColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.favorite_rounded,
          color: state.talkLevelColor,
          size: 32.sp,
        ),
      );
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isWide;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        mainAxisAlignment: isWide ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 14.sp),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: AppColors.subtitleText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isWide) ...[
                    SizedBox(height: 2.h),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
          if (isWide)
            Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
        ],
      ),
    );
  }
}
