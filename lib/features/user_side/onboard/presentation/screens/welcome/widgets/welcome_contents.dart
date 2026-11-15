import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/mint_talk_logo.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/welcome/widgets/screen_items.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/welcome/widgets/welcome_headline.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/welcome/widgets/welcome_mascot.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/welcome/widgets/welcome_tagline.dart';

class WelcomeContents extends StatelessWidget {
  const WelcomeContents({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final horizontal = EdgeInsets.symmetric(horizontal: 20.w);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 12.h),
          const Center(child: MintTalkLogo(direction: Axis.horizontal)),
          SizedBox(height: 6.h),
          const WelcomeTagline(),
          // The mascot scene runs edge to edge and absorbs the leftover
          // height, so it shrinks on short screens instead of overflowing.
          const Expanded(child: WelcomeMascot()),
          Padding(padding: horizontal, child: const WelcomeHeadline()),
          SizedBox(height: 20.h),
          Padding(
            padding: horizontal.copyWith(bottom: bottomInset + 12.h),
            child: const ScreenItems(),
          ),
        ],
      ),
    );
  }
}
