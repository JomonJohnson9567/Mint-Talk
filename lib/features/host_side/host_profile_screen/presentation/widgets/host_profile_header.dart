import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_state.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_avatar.dart';

/// Lavender hero card with the host's avatar, name, verified pill, phone and
/// the edit shortcut, with the earn mascot standing on the right.
class HostProfileHeader extends StatelessWidget {
  final HostProfileState profile;
  final VoidCallback onEdit;

  const HostProfileHeader({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  /// Below this card width the mascot is dropped so the details keep room.
  static const double _mascotMinCardWidth = 300;

  /// Native aspect ratio (width / height) of [AppAssets.hostEarnMascot].
  static const double _mascotAspectRatio = 720 / 533;

  @override
  Widget build(BuildContext context) {
    return Material(
      // The mascot image is opaque — its background matches hostPromoBanner.
      color: AppColors.hostPromoBanner,
      borderRadius: BorderRadius.circular(20.cw),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final showMascot = cardWidth >= _mascotMinCardWidth;
          final mascotWidth = showMascot
              ? (cardWidth * 0.28).clamp(0.0, 120.0)
              : 0.0;
          final avatarSize = (cardWidth * 0.22).clamp(60.0, 82.0);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16.cw,
                    18.cw,
                    showMascot ? 4.cw : 16.cw,
                    18.cw,
                  ),
                  child: Row(
                    children: [
                      _AvatarWithBadge(
                        imagePath: profile.imagePath ?? '',
                        initials: profile.initials,
                        size: avatarSize,
                      ),
                      SizedBox(width: 12.cw),
                      Expanded(
                        child: _HeaderDetails(profile: profile, onEdit: onEdit),
                      ),
                    ],
                  ),
                ),
              ),
              if (showMascot)
                SizedBox(
                  width: mascotWidth,
                  height: mascotWidth / _mascotAspectRatio,
                  child: Image.asset(
                    AppAssets.hostEarnMascot,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomRight,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AvatarWithBadge extends StatelessWidget {
  final String imagePath;
  final String initials;

  /// Outer diameter, in logical pixels (already scaled by the caller).
  final double size;

  const _AvatarWithBadge({
    required this.imagePath,
    required this.initials,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final ring = size * 0.037;
    final badgeSize = size * 0.32;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(ring),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: HostProfileAvatar(
              imagePath: imagePath,
              initials: initials,
              // HostProfileAvatar scales this itself; the tight parent
              // constraints pin the actual rendered size.
              size: 76,
            ),
          ),
        ),
        Positioned(
          right: -2.cw,
          bottom: 0,
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              color: AppColors.hostVideoAccent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 2.5.cw),
            ),
            child: Icon(
              Icons.check_rounded,
              size: badgeSize * 0.54,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderDetails extends StatelessWidget {
  final HostProfileState profile;
  final VoidCallback onEdit;

  const _HeaderDetails({required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          profile.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.nunito(
            fontSize: 20.csp,
            fontWeight: FontWeight.w800,
            color: AppColors.plumDeep,
            height: 1.2,
          ),
        ),
        SizedBox(height: 6.cw),
        const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: _VerifiedPill(),
        ),
        SizedBox(height: 6.cw),
        Row(
          children: [
            Icon(
              Icons.phone_rounded,
              size: 13.csp,
              color: AppColors.hostSubtitle,
            ),
            SizedBox(width: 4.cw),
            Flexible(
              child: Text(
                profile.displayPhone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5.csp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.hostSubtitle,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.cw),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: _EditProfileButton(onTap: onEdit),
        ),
      ],
    );
  }
}

class _VerifiedPill extends StatelessWidget {
  const _VerifiedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.cw, vertical: 3.cw),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12.cw),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 13.csp,
            color: AppColors.hostVideoAccent,
          ),
          SizedBox(width: 4.cw),
          Text(
            AppTexts.verifiedHost,
            style: TextStyle(
              fontSize: 11.5.csp,
              fontWeight: FontWeight.w700,
              color: AppColors.plumDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EditProfileButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20.cw);

    return Material(
      color: AppColors.white.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: AppColors.primaryColor, width: 1.4.cw),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 6.cw),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_outlined,
                size: 15.csp,
                color: AppColors.plumDeep,
              ),
              SizedBox(width: 6.cw),
              Text(
                AppTexts.editProfile,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13.csp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.plumDeep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
