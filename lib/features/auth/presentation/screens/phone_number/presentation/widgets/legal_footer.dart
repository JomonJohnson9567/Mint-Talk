import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';

/// "By continuing, you agree to our Terms of Service & Privacy Policy."
class LegalFooter extends StatefulWidget {
  const LegalFooter({super.key});

  @override
  State<LegalFooter> createState() => _LegalFooterState();
}

class _LegalFooterState extends State<LegalFooter> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    // The privacy policy screen holds both the terms and the privacy sections.
    _termsRecognizer = TapGestureRecognizer()..onTap = _openPolicy;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPolicy;
  }

  void _openPolicy() => Navigator.pushNamed(context, AppRoutes.privacyPolicy);

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: AppColors.plumDeep,
      fontWeight: FontWeight.w600,
    );

    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 11.sp,
          color: AppColors.plumMuted,
          height: 1.6,
        ),
        children: [
          TextSpan(text: '${AppTexts.byContinuingYouAgree}\n'),
          TextSpan(
            text: AppTexts.termsOfService,
            style: linkStyle,
            recognizer: _termsRecognizer,
          ),
          const TextSpan(text: ' & '),
          TextSpan(
            text: AppTexts.privacyPolicyLink,
            style: linkStyle,
            recognizer: _privacyRecognizer,
          ),
          TextSpan(text: '.', style: linkStyle),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
