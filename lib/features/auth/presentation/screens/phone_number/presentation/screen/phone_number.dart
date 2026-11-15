import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/auth/presentation/screens/phone_number/presentation/widgets/screen_contents.dart';

class PhoneScreen extends StatelessWidget {
  const PhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.creamBackground,
        body: ScreenContents(),
      ),
    );
  }
}
