import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/action_buttons_section.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/home_header.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/user_grid.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/user_status_tabs.dart';
import 'package:mint_talk/core/theme/color.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import 'package:mint_talk/core/widgets/top_snackbar.dart';

class HomeContents extends StatelessWidget {
  const HomeContents({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.notificationId != current.notificationId,
      listener: (context, state) {
        if (state.notificationMessage != null &&
            state.notificationMessage!.isNotEmpty) {
          Color? bgColor;
          if (state.notificationType == NotificationType.info) {
            bgColor = AppColors.termsIcon;
          } else if (state.notificationType == NotificationType.success) {
            bgColor = AppColors.favIcon;
          }
          showTopSnackBar(
            context,
            state.notificationMessage!,
            backgroundColor: bgColor,
          );
        }
      },
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 100.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              HomeHeader(),
              ActionButtonsSection(),
              UserStatusTabs(),
              UserGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
