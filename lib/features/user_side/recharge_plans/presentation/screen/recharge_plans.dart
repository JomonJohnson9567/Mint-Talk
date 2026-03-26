import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import '../widgets/screen_contents.dart';

class RechargePlans extends StatelessWidget {
  const RechargePlans({super.key});

  static const Color _screenBackground = Color(0xFFF4FAF9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBackground,
      appBar: CustomAppBar(
        title: AppTexts.rechargePlans,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(child: ScreenContents(contentWidth: 760.0)),
    );
  }
}
