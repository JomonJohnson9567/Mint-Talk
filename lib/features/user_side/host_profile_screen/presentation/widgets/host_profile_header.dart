import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Centered spotlight avatar (gradient ring + glow), followed by the host's
/// name and presence pill.
/// Tapping the photo opens it full screen.
class HostProfileHeader extends StatelessWidget {
  final String hostId;
  final String name;
  final bool isOnline;
  final bool isBusy;
  final String imageUrl;

  const HostProfileHeader({
    super.key,
    required this.hostId,
    required this.name,
    required this.isOnline,
    required this.isBusy,
    required this.imageUrl,
  });

  // Same presence mapping as the home grid cards.
  Color get _statusColor {
    if (isOnline) return AppColors.onlineIndicator;
    if (isBusy) return AppColors.termsIcon;
    return AppColors.favIcon;
  }

  String get _statusLabel {
    if (isOnline) return AppTexts.online;
    if (isBusy) return AppTexts.onCall;
    return AppTexts.offline;
  }

  String get _heroTag => 'host-avatar-$hostId';

  void _openPhoto(BuildContext context) {
    // A PageRoute (not showDialog) so the Hero flight runs.
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) =>
            _AvatarViewer(heroTag: _heroTag, imageUrl: imageUrl),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: imageUrl.isEmpty ? null : () => _openPhoto(context),
          child: _SpotlightAvatar(
            heroTag: _heroTag,
            imageUrl: imageUrl,
            statusColor: _statusColor,
          ),
        ),
        SizedBox(height: 10.cw),
        Text(
          name.trim().isNotEmpty ? name.trim() : 'Host',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 26.csp,
            fontWeight: FontWeight.w800,
            color: AppColors.plumDeep,
            height: 1.15,
          ),
        ),
        SizedBox(height: 8.cw),
        _StatusPill(color: _statusColor, label: _statusLabel),
      ],
    );
  }
}

/// Headset mascot shown at the right end of the page header. The PNG has an
/// opaque background, so it's masked to a soft circle that melts into the
/// page gradient.
class HostProfileMascot extends StatelessWidget {
  const HostProfileMascot({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => const RadialGradient(
        radius: 0.55,
        colors: [AppColors.black, AppColors.transparent],
        stops: [0.7, 1.0],
      ).createShader(bounds),
      child: Image.asset(AppAssets.applyHostMascot, fit: BoxFit.cover),
    );
  }
}

/// Photo inside a white gap and a plum → magenta → coral ring, with a soft
/// halo and glow behind it.
class _SpotlightAvatar extends StatelessWidget {
  const _SpotlightAvatar({
    required this.heroTag,
    required this.imageUrl,
    required this.statusColor,
  });

  final String heroTag;
  final String imageUrl;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final size = 140.cw;

    return SizedBox(
      width: 172.cw,
      height: 172.cw,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.white.withValues(alpha: 0.9),
                  AppColors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(4.cw),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor,
                  AppColors.linkMagenta,
                  AppColors.audioAccent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.28),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.all(4.cw),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Hero(
                tag: heroTag,
                child: ClipOval(child: _AvatarImage(imageUrl: imageUrl)),
              ),
            ),
          ),
          Positioned(
            // Sits on the ring at roughly the 4–5 o'clock position.
            right: 26.cw,
            bottom: 26.cw,
            child: Container(
              width: 24.cw,
              height: 24.cw,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 4.cw),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.imageUrl, this.fit = BoxFit.cover});

  final String imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(AppAssets.femaleIcon, fit: fit);
    if (imageUrl.isEmpty) return fallback;
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        errorWidget: (context, url, error) => fallback,
      );
    }
    return Image.asset(imageUrl, fit: fit);
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.cw, vertical: 5.cw),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20.cw),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.cw,
            height: 8.cw,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.cw),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5.csp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen photo with pinch-to-zoom; tap anywhere to close.
class _AvatarViewer extends StatelessWidget {
  const _AvatarViewer({required this.heroTag, required this.imageUrl});

  final String heroTag;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.plumDeep.withValues(alpha: 0.94),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20.cw),
                  child: Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.cw),
                      child: InteractiveViewer(
                        maxScale: 4,
                        child: _AvatarImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8.cw,
                right: 8.cw,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.white,
                    size: 28.csp,
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
