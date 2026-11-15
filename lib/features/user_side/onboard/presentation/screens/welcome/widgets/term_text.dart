import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/cubit/welcome/welcome_cubit.dart';

/// "Before you begin, please review our Terms & Conditions and Privacy Policy."
class TermsText extends StatefulWidget {
  const TermsText({super.key});

  @override
  State<TermsText> createState() => _TermsTextState();
}

class _TermsTextState extends State<TermsText> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    // The privacy policy screen holds both the terms and the privacy sections.
    _termsRecognizer = TapGestureRecognizer()..onTap = _openPolicy;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPolicy;
  }

  /// Agree / Decline on the policy page ticks / unticks the checkbox; leaving
  /// with the back button keeps it as it was.
  Future<void> _openPolicy() async {
    // Untyped push: AppRouter builds `Route<dynamic>`, so `pushNamed<bool>`
    // would fail its route cast and never open the page.
    final agreed = await Navigator.pushNamed(context, AppRoutes.privacyPolicy);
    if (agreed is bool && mounted) {
      context.read<WelcomeCubit>().toggleAgreement(agreed);
    }
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.plumMuted,
    );

    return Text.rich(
      TextSpan(
        style: TextStyle(
          color: AppColors.plumDeep,
          fontSize: 14.sp,
          height: 1.5,
        ),
        children: [
          TextSpan(text: AppTexts.beforeYouBeginReview),
          TextSpan(
            text: AppTexts.termsAndConditionsLink,
            style: linkStyle,
            recognizer: _termsRecognizer,
          ),
          TextSpan(text: AppTexts.and),
          TextSpan(
            text: AppTexts.privacyPolicyLink,
            style: linkStyle,
            recognizer: _privacyRecognizer,
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
