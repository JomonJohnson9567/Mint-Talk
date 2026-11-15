import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Title/subtitle card with a mascot on the right, used at the top of the
/// host side pages (same shape as the dashboard's greeting banner).
///
/// Opaque mascots must be paired with the [backgroundColor] they were
/// sampled from so their edges blend into the card; transparent PNGs work on
/// any background.
class HostMascotBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String mascotAsset;
  final Color backgroundColor;
  final double mascotHeight;

  const HostMascotBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.mascotAsset,
    this.backgroundColor = AppColors.hostGreetingBanner,
    this.mascotHeight = 104,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 96.cw),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.cw, 16.cw, 4.cw, 16.cw),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 19.csp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.plumDeep,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 6.cw),
                  Text(
                    subtitle,
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
          ),
          Image.asset(
            mascotAsset,
            height: mascotHeight.cw,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
