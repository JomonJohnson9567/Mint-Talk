import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

/// Plum chat-bubble mark with the "MintTalk" wordmark — stacked above it by
/// default, or beside it when [direction] is [Axis.horizontal].
class MintTalkLogo extends StatelessWidget {
  final Axis direction;

  const MintTalkLogo({super.key, this.direction = Axis.vertical});

  @override
  Widget build(BuildContext context) {
    final isHorizontal = direction == Axis.horizontal;

    return Flex(
      direction: direction,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _ChatBubbleMark(),
        isHorizontal ? SizedBox(width: 10.w) : SizedBox(height: 4.h),
        Text(
          AppTexts.appName,
          style: GoogleFonts.nunito(
            fontSize: isHorizontal ? 32.sp : 28.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.plumDeep,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _ChatBubbleMark extends StatelessWidget {
  const _ChatBubbleMark();

  @override
  Widget build(BuildContext context) {
    final width = 48.w;
    final bodyHeight = 33.w;
    final tailHeight = 9.w;

    return SizedBox(
      width: width,
      height: bodyHeight + tailHeight,
      child: CustomPaint(
        painter: _BubblePainter(
          color: AppColors.primaryColor,
          bodyHeight: bodyHeight,
          tailHeight: tailHeight,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: bodyHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (_) => Container(
                  width: 6.w,
                  height: 6.w,
                  margin: EdgeInsets.symmetric(horizontal: 2.2.w),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Color color;
  final double bodyHeight;
  final double tailHeight;

  const _BubblePainter({
    required this.color,
    required this.bodyHeight,
    required this.tailHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, bodyHeight),
      Radius.circular(bodyHeight / 2),
    );
    canvas.drawRRect(body, paint);

    // Tail pointing down-left from the lower-left of the bubble.
    final tail = Path()
      ..moveTo(size.width * 0.22, bodyHeight - 2)
      ..lineTo(size.width * 0.14, bodyHeight + tailHeight)
      ..lineTo(size.width * 0.44, bodyHeight - 2)
      ..close();
    canvas.drawPath(tail, paint);
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.bodyHeight != bodyHeight ||
      oldDelegate.tailHeight != tailHeight;
}
