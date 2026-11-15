import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/privacy_policy/widgets/terms_sections_list.dart';

/// Host settings → Terms & Conditions: the same MintTalk terms shown on the
/// welcome screen and accepted during the host application.
class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: CustomAppBar(
        title: 'Terms & Conditions',
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(top: false, child: TermsSectionsList()),
    );
  }
}
