import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/home_header.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/models/video_call_online_user.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/widgets/video_call_online_user_card.dart';

class VideoCallOnlineContents extends StatelessWidget {
  const VideoCallOnlineContents({super.key});

  @override
  Widget build(BuildContext context) {
    const users = VideoCallOnlineUser.sampleUsers;
    final width = MediaQuery.sizeOf(context).width;
    int crossAxisCount = 3;
    if (width >= 1200) {
      crossAxisCount = 6;
    } else if (width >= 900) {
      crossAxisCount = 5;
    } else if (width >= 600) {
      crossAxisCount = 4;
    }

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeader(),
          Expanded(
            child: CustomScrollView(
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
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          VideoCallOnlineUserCard(user: users[index]),
                      childCount: users.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 14.h,
                      crossAxisSpacing: 14.w,
                      mainAxisExtent: 252.h,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

