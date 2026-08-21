import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/cubit/user_recharge_history_cubit.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/cubit/user_recharge_history_state.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/widgets/recharge_history_empty_state.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/widgets/recharge_history_item_card.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/widgets/recharge_history_summary_card.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/widgets/user_recharge_history_skeleton.dart';

class UserRechargeHistoryContents extends StatelessWidget {
  const UserRechargeHistoryContents({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRechargeHistoryCubit, UserRechargeHistoryState>(
      builder: (context, state) {
        if (state.isLoading && state.visibleHistory.isEmpty) {
          return const UserRechargeHistorySkeleton();
        }

        if (state.status == UserRechargeHistoryStatus.failure &&
            state.visibleHistory.isEmpty) {
          return _FailureState(
            message: state.errorMessage ?? 'Failed to load recharge history',
            onRetry: () => context.read<UserRechargeHistoryCubit>().loadHistory(),
          );
        }

        if (state.visibleHistory.isEmpty) {
          return RechargeHistoryEmptyState(
            onRefresh: () => context.read<UserRechargeHistoryCubit>().refreshHistory(),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () => context.read<UserRechargeHistoryCubit>().refreshHistory(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 160) {
                context.read<UserRechargeHistoryCubit>().loadMore();
              }
              return false;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
              // index 0 = summary header, last index = footer (loading-more
              // spinner / end-of-list text / nothing), everything in
              // between is a lazily-built history item.
              itemCount: state.visibleHistory.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 18.h),
                    child: RechargeHistorySummaryCard(history: state.history),
                  );
                }

                final itemIndex = index - 1;
                if (itemIndex < state.visibleHistory.length) {
                  return RechargeHistoryItemCard(
                    item: state.visibleHistory[itemIndex],
                  );
                }

                if (state.isLoadingMore) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                        strokeWidth: 2.4,
                      ),
                    ),
                  );
                }

                if (!state.hasMore && state.visibleHistory.isNotEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 6.h, bottom: 6.h),
                    child: Center(
                      child: Text(
                        'You have reached the end of your recharge history.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.subtitleText,
                        ),
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }
}

class _FailureState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FailureState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52.sp,
              color: AppColors.red,
            ),
            SizedBox(height: 12.h),
            Text(
              'Unable to load recharge history',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.subtitleText,
                height: 1.45,
              ),
            ),
            SizedBox(height: 18.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
