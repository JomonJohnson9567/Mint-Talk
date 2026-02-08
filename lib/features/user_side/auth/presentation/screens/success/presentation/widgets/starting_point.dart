import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/success/presentation/widgets/success_content.dart';

class ScreenStartPoint extends StatelessWidget {
  const ScreenStartPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned(
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(AppAssets.success, fit: BoxFit.contain),
          ),
        ),

        const SuccessContent(),
      ],
    );
  }
}
