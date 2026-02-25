import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';

import 'package:mint_talk/features/user_side/onboard/presentation/screens/privacy_policy/widgets/text_contents.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: AppTexts.termsAndConditions,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(child: TextContents()),
    );
  }
}
