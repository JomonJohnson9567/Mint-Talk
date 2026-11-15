import 'package:flutter/material.dart';

import 'package:mint_talk/features/user_side/home/presentation/widgets/action_buttons_section.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/greeting_banner.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/home_header.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/host_list_listeners.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/user_grid.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/user_status_tabs.dart';

class HomeContents extends StatelessWidget {
  const HomeContents({super.key});

  @override
  Widget build(BuildContext context) {
    return const HostListListeners(
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(),
            Expanded(
              child: UserGrid(
                header: Column(
                  children: [
                    GreetingBanner(),
                    ActionButtonsSection(),
                    UserStatusTabs(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
