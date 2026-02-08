import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/otp_verification/presentation/widgets/otp_body.dart';
import 'package:mint_talk/core/transitions/utils/morphing_flight_shuttle.dart';

class OtpContents extends StatelessWidget {
  const OtpContents({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 280.h,
          child: Center(
            child: Hero(
              tag: 'morphing_image',
              flightShuttleBuilder: morphingImageFlightShuttleBuilder,
              child: Image.asset(AppAssets.otpEntry, fit: BoxFit.contain),
            ),
          ),
        ),
        Align(alignment: Alignment.bottomCenter, child: const OtpBody()),
      ],
    );
  }
}
