import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

/// "Just a voice away" banner with the headset mascot, shown above the host
/// search on the audio-call hosts screen.
class AudioCallBanner extends StatelessWidget {
  const AudioCallBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final height = 96.cw;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 5.cw),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.audioCardBg,
          borderRadius: BorderRadius.circular(20.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.cw, 10.cw, 0, 10.cw),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTexts.voiceAway,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.csp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.plumDeep,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.cw),
                    Text(
                      AppTexts.audioBannerSubtitle,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 13.csp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.plumMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Unlike the video mascot, this image has a painted pastel
            // background, so its left edge is faded out to melt into the
            // banner colour instead of showing a hard seam.
            ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.transparent, Colors.black],
                stops: [0, 0.35],
              ).createShader(bounds),
              child: Image.asset(
                AppAssets.applyHostMascot,
                width: height * 1.15,
                height: height,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
