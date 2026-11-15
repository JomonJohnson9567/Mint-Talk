import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// The video mascot in a ringed circle with two ripples pulsing outward —
/// the focal point over your own camera while the call is being set up.
class VideoCallRingingAvatar extends StatefulWidget {
  const VideoCallRingingAvatar({super.key});

  @override
  State<VideoCallRingingAvatar> createState() => _VideoCallRingingAvatarState();
}

class _VideoCallRingingAvatarState extends State<VideoCallRingingAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = 148.cw;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Two ripples half a cycle apart.
          for (final phase in const [0.0, 0.5])
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = (_controller.value + phase) % 1;
                  return Transform.scale(
                    scale: 1 + 0.9 * t,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white.withValues(
                            alpha: 0.55 * (1 - t),
                          ),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.creamBackground,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.9),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.35),
                    blurRadius: 32,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  AppAssets.videoCallMascot,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
