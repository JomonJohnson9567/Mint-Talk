import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/auth/presentation/screens/otp_verification/presentation/widgets/otp_contents.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract phone and countryCode from route arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final phone = args?['phone'] as String? ?? '';
    final countryCode = args?['countryCode'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.tealBackground,
      body: OtpContents(phone: phone, countryCode: countryCode),
    );
  }
}
