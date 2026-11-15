import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Lavender hero card introducing the host programme, with the headset
/// mascot faded in on the right.
class ApplyHostHeroCard extends StatelessWidget {
  const ApplyHostHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.cw),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.videoCardBg, AppColors.cardWhite],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: 150.cw,
              child: const _FadedMascot(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.cw, 20.cw, 118.cw, 20.cw),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppTexts.becomeMintTalkHost,
                    style: GoogleFonts.nunito(
                      fontSize: 20.csp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.plumDeep,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 6.cw),
                  Text(
                    AppTexts.applyHostPitch,
                    style: TextStyle(
                      fontSize: 13.csp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.plumMuted,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 14.cw),
                  const _ReviewPill(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The mascot PNG has an opaque background, so its left edge is masked out
/// to melt into the card gradient.
class _FadedMascot extends StatelessWidget {
  const _FadedMascot();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColors.transparent, AppColors.black],
        stops: [0.0, 0.4],
      ).createShader(bounds),
      child: Image.asset(AppAssets.applyHostMascot, fit: BoxFit.cover),
    );
  }
}

class _ReviewPill extends StatelessWidget {
  const _ReviewPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.cw, vertical: 6.cw),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20.cw),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 14.csp,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 5.cw),
          Flexible(
            child: Text(
              AppTexts.reviewedIn24Hours,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5.csp,
                fontWeight: FontWeight.w700,
                color: AppColors.plumDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
