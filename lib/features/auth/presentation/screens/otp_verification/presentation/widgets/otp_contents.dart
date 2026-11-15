import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
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
        // Hero background so the phone screen's wave card morphs into the
        // soft surface behind the form instead of disappearing.
        Positioned.fill(
          child: Hero(
            tag: 'morphing_bottom_container',
            flightShuttleBuilder: morphingContainerFlightShuttleBuilder,
            child: const Material(
              color: Colors.transparent,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.creamBackground, AppColors.cardWhite],
                    stops: [0.3, 0.6],
                  ),
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          // The form keeps its compact size; the illustration takes whatever
          // height is left, so everything fits above the keyboard.
          child: Column(
            children: [
              const _OtpTopBar(),
              const Flexible(child: _OtpIllustration()),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  4.h,
                  20.w,
                  MediaQuery.paddingOf(context).bottom + 12.h,
                ),
                child: OtpBody(phone: phone, countryCode: countryCode),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Back chevron on the left with the "MintTalk" wordmark centred.
class _OtpTopBar extends StatelessWidget {
  const _OtpTopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 6.w),
              child: IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.plumDeep,
                  size: 20.sp,
                ),
              ),
            ),
          ),
          Text(
            AppTexts.appName,
            style: GoogleFonts.nunito(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.plumDeep,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpIllustration extends StatelessWidget {
  const _OtpIllustration();

  @override
  Widget build(BuildContext context) {
    // Full width at most, shrinking (and centring) when height is tight.
    // heightFactor keeps Center from filling the Flexible's spare space.
    return Center(
      heightFactor: 1,
      child: AspectRatio(
        aspectRatio: 2,
        child: Hero(
          tag: 'morphing_image',
          flightShuttleBuilder: morphingImageFlightShuttleBuilder,
          // The illustration carries its own wavy backdrop, so fade all four
          // edges into the page background.
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: [0.0, 0.06, 0.94, 1.0],
            ).createShader(rect),
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                ],
                stops: [0.0, 0.1, 0.85, 1.0],
              ).createShader(rect),
              child: Image.asset(AppAssets.otpEntry, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}
