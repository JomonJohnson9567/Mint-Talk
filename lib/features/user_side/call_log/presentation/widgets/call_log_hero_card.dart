import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Lavender banner at the top of the call history, with the mascot faded in
/// on the right.
class CallLogHeroCard extends StatelessWidget {
  const CallLogHeroCard({super.key});

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
              padding: EdgeInsets.fromLTRB(18.cw, 22.cw, 132.cw, 22.cw),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppTexts.yourConversations,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 21.csp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.plumDeep,
                    ),
                  ),
                  SizedBox(height: 4.cw),
                  Text(
                    AppTexts.callHistoryTagline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.csp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.plumMuted,
                      height: 1.35,
                    ),
                  ),
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
        stops: [0.0, 0.35],
      ).createShader(bounds),
      child: Image.asset(AppAssets.callLogMascot, fit: BoxFit.cover),
    );
  }
}
