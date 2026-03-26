import 'package:flutter/material.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_screen_contents.dart';
import '../../../../../core/theme/color.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.callBackground,
      body: const CallScreenContents(),
    );
  }
}
