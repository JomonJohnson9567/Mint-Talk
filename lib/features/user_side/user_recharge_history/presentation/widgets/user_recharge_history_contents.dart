import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/cubit/user_recharge_history_cubit.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/cubit/user_recharge_history_state.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/widgets/recharge_history_empty_state.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/widgets/recharge_history_item_card.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/widgets/recharge_history_summary_card.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/widgets/user_recharge_history_skeleton.dart';

class UserRechargeHistoryContents extends StatelessWidget {
  const UserRechargeHistoryContents({super.key});

  /// Same cap as the recharge plans screen so tablets get a centred column.
  static const double _contentWidth = 760.0;

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
            message: state.errorMessage ?? AppTexts.unableToLoadHistory,
            onRetry: () =>
                context.read<UserRechargeHistoryCubit>().loadHistory(),
          );
        }

        if (state.visibleHistory.isEmpty) {
          return RechargeHistoryEmptyState(
            onRefresh: () =>
                context.read<UserRechargeHistoryCubit>().refreshHistory(),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Padding (rather than a ConstrainedBox) caps the width so the
            // ListView stays lazy and still scrolls edge to edge.
            final horizontalPadding = math.max(
              16.cw,
              (constraints.maxWidth - _contentWidth) / 2,
            );

            return RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: () =>
                  context.read<UserRechargeHistoryCubit>().refreshHistory(),
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
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    4.cw,
                    horizontalPadding,
                    24.cw,
                  ),
                  // index 0 = summary header + section title, last index =
                  // footer (loading-more spinner / end-of-list text /
                  // nothing), everything in between is a lazily-built
                  // history item.
                  itemCount: state.visibleHistory.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RechargeHistorySummaryCard(history: state.history),
                          SizedBox(height: 22.cw),
                          Text(
                            AppTexts.yourRecharges,
                            style: GoogleFonts.nunito(
                              fontSize: 18.csp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.plumDeep,
                            ),
                          ),
                          SizedBox(height: 12.cw),
                        ],
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
                        padding: EdgeInsets.symmetric(vertical: 14.cw),
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
                        padding: EdgeInsets.symmetric(vertical: 8.cw),
                        child: Center(
                          child: Text(
                            AppTexts.rechargeHistoryEnd,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.csp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.plumHint,
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
      },
    );
  }
}

class _FailureState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FailureState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.cw),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppAssets.rechargeMascot, width: 130.cw),
            SizedBox(height: 16.cw),
            Text(
              AppTexts.unableToLoadHistory,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 20.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
            SizedBox(height: 8.cw),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.csp,
                color: AppColors.plumMuted,
                height: 1.45,
              ),
            ),
            SizedBox(height: 20.cw),
            PrimaryButton(
              text: AppTexts.retry,
              width: 160.cw,
              height: 46.cw,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
