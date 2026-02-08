import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/transitions/utils/morphing_flight_shuttle.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/welcome/widgets/screen_items.dart';

class WelcomeContents extends StatelessWidget {
  const WelcomeContents({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Hero(
              tag: 'morphing_image',
              flightShuttleBuilder: morphingImageFlightShuttleBuilder,
              child: Image.asset(
                AppAssets.welcomeBackground,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Bottom Sheet Content
        const Align(alignment: Alignment.bottomCenter, child: ScreenItems()),
      ],
    );
  }
}
