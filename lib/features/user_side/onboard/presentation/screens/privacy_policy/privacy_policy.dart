import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/privacy_policy/widgets/text_contents.dart';

/// Terms & privacy page. Pops `true` on Agree and `false` on Decline so the
/// welcome screen can sync its agreement checkbox.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(bottom: false, child: TextContents()),
    );
  }
}
