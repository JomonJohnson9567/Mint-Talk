import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/transitions/utils/morphing_flight_shuttle.dart';
import 'package:mint_talk/features/auth/presentation/screens/otp_verification/presentation/widgets/otp_body.dart';

class OtpContents extends StatelessWidget {
  final String phone;
  final String countryCode;

  const OtpContents({
    super.key,
    required this.phone,
    required this.countryCode,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 280.h,
          child: const Center(child: _OtpIllustration()),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: OtpBody(phone: phone, countryCode: countryCode),
        ),
      ],
    );
  }
}

class _OtpIllustration extends StatelessWidget {
  const _OtpIllustration();

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'morphing_image',
      flightShuttleBuilder: morphingImageFlightShuttleBuilder,
      child: Image.asset(AppAssets.otpEntry, fit: BoxFit.contain),
    );
  }
}
