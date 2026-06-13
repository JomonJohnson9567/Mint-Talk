import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/home_header.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/cubit/online_users_cubit.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/cubit/online_users_state.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/widgets/video_call_online_user_card.dart';

class VideoCallOnlineContents extends StatelessWidget {
  const VideoCallOnlineContents({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnlineUsersCubit>(),
      child: const _VideoCallOnlineView(),
    );
  }
}

class _VideoCallOnlineView extends StatelessWidget {
  const _VideoCallOnlineView();

  Widget _buildTab(
    BuildContext context,
    String title,
    VideoCallFilterTab tab,
    VideoCallFilterTab selectedTab,
  ) {
    final bool isSelected = selectedTab == tab;
    return GestureDetector(
      onTap: () => context.read<OnlineUsersCubit>().selectTab(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.23),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textGrey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 3;
                if (constraints.maxWidth >= 1200) {
                  crossAxisCount = 6;
                } else if (constraints.maxWidth >= 900) {
                  crossAxisCount = 5;
                } else if (constraints.maxWidth >= 600) {
                  crossAxisCount = 4;
                } else if (constraints.maxWidth < 350) {
                  crossAxisCount = 3;
                }

                return BlocBuilder<OnlineUsersCubit, OnlineUsersState>(
                  builder: (context, state) {
                    final users = state.users;
                    final selectedTab = state.selectedTab;

                    return CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppTexts.availableNow,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  AppTexts.videoCallHostsSubtitle,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    height: 1.5,
                                    color: AppColors.subtitleText,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildTab(
                                      context,
                                      AppTexts.active,
                                      VideoCallFilterTab.active,
                                      selectedTab,
                                    ),
                                    _buildTab(
                                      context,
                                      AppTexts.favorites,
                                      VideoCallFilterTab.favorites,
                                      selectedTab,
                                    ),
                                    _buildTab(
                                      context,
                                      AppTexts.offline,
                                      VideoCallFilterTab.offline,
                                      selectedTab,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (users.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'No users found',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding:
                                EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    VideoCallOnlineUserCard(user: users[index]),
                                childCount: users.length,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 14.h,
                                crossAxisSpacing: 14.w,
                                mainAxisExtent: 340.h,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
