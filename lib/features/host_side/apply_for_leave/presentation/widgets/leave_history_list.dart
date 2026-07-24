import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/presentation/cubit/apply_for_leave_cubit.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/presentation/cubit/apply_for_leave_state.dart';

class LeaveHistoryList extends StatelessWidget {
  const LeaveHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApplyForLeaveCubit, ApplyForLeaveState>(
      builder: (context, state) {
        if (state.historyStatus == LeaveHistoryStatus.loading ||
            state.historyStatus == LeaveHistoryStatus.initial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (state.historyStatus == LeaveHistoryStatus.failure) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Text(
                state.errorMessage ?? 'Unable to load leave history',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (state.history.isEmpty) {
          return Center(
            child: Text(
              'No leave requests yet.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.subtitleText,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(20.w),
          itemCount: state.history.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final item = state.history[index];
            final statusColor = switch (item.status.toLowerCase()) {
              'approved' => AppColors.onlineIndicator,
              'rejected' => AppColors.callEndedStatus,
              _ => AppColors.orange,
            };

            return Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.event_available_rounded, color: statusColor, size: 18.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_formatDate(item.startDate)} - ${_formatDate(item.endDate)}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _formatDate(item.createdAt),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.subtitleText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          item.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    item.reason,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.subtitleText,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    return '$day/$month/$year';
  }
}
