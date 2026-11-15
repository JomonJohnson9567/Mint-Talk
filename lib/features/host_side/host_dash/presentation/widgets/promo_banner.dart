import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'host_dash_motion.dart';

/// [earn] sits on the idle dashboard; [waiting] is shown while the host is
/// online, with the mascot on the left.
enum PromoBannerVariant { earn, waiting }

class PromoBanner extends StatelessWidget {
  final PromoBannerVariant variant;

  const PromoBanner({super.key, this.variant = PromoBannerVariant.earn});

  @override
  Widget build(BuildContext context) {
    final bool isWaiting = variant == PromoBannerVariant.waiting;

    // TODO: swap in the bag-holding mascot for the waiting variant once the
    // asset is supplied — it reuses the coin mascot for now.
    // Takes ~45% of the card and pins the mascot to its outer bottom corner,
    // so the text keeps room on small phones.
    final Widget mascot = Expanded(
      flex: 9,
      child: Padding(
        padding: EdgeInsets.only(top: 6.cw),
        child: Image.asset(
          AppAssets.hostEarnMascot,
          height: 96.cw,
          fit: BoxFit.contain,
          alignment: isWaiting ? Alignment.bottomLeft : Alignment.bottomRight,
        ),
      ),
    );

    final Widget text = Expanded(
      flex: 11,
      child: Padding(
        padding: isWaiting
            ? EdgeInsets.fromLTRB(4.cw, 16.cw, 18.cw, 16.cw)
            : EdgeInsets.fromLTRB(18.cw, 16.cw, 4.cw, 16.cw),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isWaiting
                  ? AppTexts.everyConversationCounts
                  : AppTexts.stayActiveEarnMore,
              style: TextStyle(
                fontSize: 16.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
                height: 1.2,
              ),
            ),
            SizedBox(height: 5.cw),
            Text(
              isWaiting
                  ? AppTexts.presenceMakesDifference
                  : AppTexts.stayActiveSubtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5.csp,
                color: AppColors.hostSubtitle,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 5.cw),
      child: Container(
        constraints: BoxConstraints(minHeight: 104.cw),
        decoration: BoxDecoration(
          // The mascot image is opaque — its background matches
          // hostPromoBanner. The waiting design calls for a peach card, which
          // needs the (peach-backed) bag mascot before it can switch over.
          color: AppColors.hostPromoBanner,
          borderRadius: BorderRadius.circular(22.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: HostDashSwitcher(
          child: Row(
            key: ValueKey(variant),
            crossAxisAlignment: CrossAxisAlignment.end,
            children: isWaiting ? [mascot, text] : [text, mascot],
          ),
        ),
      ),
    );
  }
}
