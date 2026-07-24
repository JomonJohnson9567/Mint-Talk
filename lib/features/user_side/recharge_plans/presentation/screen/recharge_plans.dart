import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import '../widgets/screen_contents.dart';

class RechargePlans extends StatelessWidget {
  const RechargePlans({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: AppTexts.rechargePlans,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            tooltip: 'Recharge history',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.userRechargeHistory);
            },
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: SafeArea(child: ScreenContents(contentWidth: 760.0)),
    );
  }
}
