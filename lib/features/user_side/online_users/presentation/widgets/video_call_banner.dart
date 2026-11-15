import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

/// "A smile away" banner with the video-call mascot, shown above the host
/// search on the video-call hosts screen.
class VideoCallBanner extends StatelessWidget {
  const VideoCallBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 5.cw),
      child: Container(
        constraints: BoxConstraints(minHeight: 84.cw),
        decoration: BoxDecoration(
          color: AppColors.videoCallBanner,
          borderRadius: BorderRadius.circular(20.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.cw, 10.cw, 4.cw, 10.cw),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTexts.smileAway,
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
                      AppTexts.findSomeoneToTalk,
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
            // The mascot image is opaque — its background matches
            // AppColors.videoCallBanner, so it reads as part of the banner.
            Image.asset(
              AppAssets.videoCallMascot,
              height: 84.cw,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
