import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'refer_host_sheet.dart';

/// "Refer a host" card shown under the promo banner. Tapping the card opens
/// [ReferHostSheet]; the (i) button toggles a speech bubble explaining the
/// reward terms.
class ReferHostBanner extends StatefulWidget {
  const ReferHostBanner({super.key});

  @override
  State<ReferHostBanner> createState() => _ReferHostBannerState();
}

class _ReferHostBannerState extends State<ReferHostBanner> {
  bool _showInfo = false;

  void _toggleInfo() {
    HapticFeedback.selectionClick();
    setState(() => _showInfo = !_showInfo);
  }

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 220);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 5.cw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSize(
            duration: duration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomRight,
            child: AnimatedSwitcher(
              duration: duration,
              child: _showInfo
                  ? const _InfoBubble(key: ValueKey('info'))
                  : const SizedBox(width: double.infinity),
            ),
          ),
          _ReferCard(
            onTap: () => ReferHostSheet.show(context),
            onInfoTap: _toggleInfo,
            infoActive: _showInfo,
          ),
        ],
      ),
    );
  }
}

class _ReferCard extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onInfoTap;
  final bool infoActive;

  const _ReferCard({
    required this.onTap,
    required this.onInfoTap,
    required this.infoActive,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18.r);

    return Material(
      color: AppColors.hostGreetingBanner,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: AppColors.primaryColor.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(14.cw, 12.cw, 6.cw, 12.cw),
          child: Row(
            children: [
              Container(
                width: 44.cw,
                height: 44.cw,
                decoration: BoxDecoration(
                  color: AppColors.hostAvatarBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 24.cw,
                  color: AppColors.primaryColor,
                ),
              ),
              Container(
                width: 1,
                height: 36.cw,
                margin: EdgeInsets.symmetric(horizontal: 12.cw),
                color: AppColors.profileDivider,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppTexts.referAHost,
                      style: TextStyle(
                        fontSize: 16.csp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.plumDeep,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 3.cw),
                    Text(
                      AppTexts.referHostSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5.csp,
                        color: AppColors.hostSubtitle,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onInfoTap,
                tooltip: AppTexts.referHostInfoTooltip,
                icon: Icon(
                  infoActive ? Icons.info_rounded : Icons.info_outline_rounded,
                  size: 24.cw,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lavender speech bubble whose tail points down at the (i) button.
class _InfoBubble extends StatelessWidget {
  const _InfoBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.hostVideoAccent.withValues(alpha: 0.45);

    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.78,
        child: Padding(
          padding: EdgeInsets.only(bottom: 4.cw),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.cw,
                  vertical: 10.cw,
                ),
                decoration: BoxDecoration(
                  color: AppColors.hostPromoBanner,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.plumDeep.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  AppTexts.referHostInfo,
                  style: TextStyle(
                    fontSize: 13.csp,
                    color: AppColors.plumDeep,
                    height: 1.35,
                  ),
                ),
              ),
              // Sits over the IconButton's centre (≈ 30cw from the card edge).
              Padding(
                padding: EdgeInsets.only(right: 24.cw),
                child: CustomPaint(
                  size: Size(14.cw, 8.cw),
                  painter: _BubbleTailPainter(
                    fill: AppColors.hostPromoBanner,
                    border: borderColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color fill;
  final Color border;

  const _BubbleTailPainter({required this.fill, required this.border});

  @override
  void paint(Canvas canvas, Size size) {
    // Overlap the bubble by 1px so the bubble's bottom border is hidden.
    final path = Path()
      ..moveTo(0, -1)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, -1);

    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_BubbleTailPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.border != border;
}
