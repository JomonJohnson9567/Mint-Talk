import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/home_user_entity.dart';
import 'package:mint_talk/features/user_side/host_profile_screen/presentation/widgets/host_profile_header.dart';
import 'package:mint_talk/features/user_side/host_profile_screen/presentation/widgets/host_special_categories.dart';
import 'package:mint_talk/features/user_side/host_profile_screen/presentation/widgets/host_warning_banner.dart';
import 'package:mint_talk/features/user_side/host_profile_screen/presentation/widgets/host_action_buttons.dart';
 
class ScreenContents extends StatelessWidget {
  final HomeUserEntity user;

  const ScreenContents({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          SizedBox(height: 10.h),
          HostProfileHeader(
            name: user.name,
            isOnline: user.status == UserStatus.online,
            imageUrl: user.imageUrl,
          ),
          SizedBox(height: 24.h),
          const HostActionButtons(),
          SizedBox(height: 24.h),

          const HostSpecialCategories(),
          SizedBox(height: 40.h),
          const HostWarningBanner(),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
