import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import '../../domain/entities/blocked_user_entity.dart';

/// One blocked host/user: avatar with a block badge, name, when they were
/// blocked and an Unblock pill.
class BlockedUserTile extends StatelessWidget {
  final BlockedUserEntity user;
  final String name;
  final VoidCallback onUnblock;
  final bool showDivider;

  const BlockedUserTile({
    super.key,
    required this.user,
    required this.name,
    required this.onUnblock,
    this.showDivider = true,
  });

  static const double _avatarSize = 56;

  @override
  Widget build(BuildContext context) {
    final subtitle = _subtitle;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.cw),
          child: Row(
            children: [
              _Avatar(imageUrl: user.avatarUrl),
              SizedBox(width: 14.cw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 16.5.csp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.plumDeep,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4.cw),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.csp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.plumMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 12.cw),
              _UnblockPill(onTap: onUnblock),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: (_avatarSize + 14).cw,
            color: AppColors.profileDivider,
          ),
      ],
    );
  }

  /// `Blocked 12 Oct` (year added for earlier years), else the role.
  String? get _subtitle {
    final createdAt = user.createdAt;
    if (createdAt != null) {
      return '${AppTexts.blockedOn} ${_formatDate(createdAt.toLocal())}';
    }
    if (user.role.isNotEmpty) {
      return user.role[0].toUpperCase() + user.role.substring(1).toLowerCase();
    }
    return null;
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _formatDate(DateTime date) {
    final dayMonth = '${date.day} ${_months[date.month - 1]}';
    return date.year == DateTime.now().year
        ? dayMonth
        : '$dayMonth ${date.year}';
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;

  const _Avatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final size = BlockedUserTile._avatarSize.cw;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          ClipOval(
            child: SizedBox(
              width: size,
              height: size,
              child: imageUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          Image.asset(AppAssets.femaleIcon, fit: BoxFit.cover),
                    )
                  : Image.asset(AppAssets.femaleIcon, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 20.cw,
              height: 20.cw,
              decoration: BoxDecoration(
                color: AppColors.blockedIcon,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2.cw),
              ),
              child: Icon(
                Icons.block_rounded,
                size: 11.csp,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnblockPill extends StatelessWidget {
  final VoidCallback onTap;

  const _UnblockPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20.cw);

    return Material(
      color: AppColors.audioBtnBg,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          height: 36.cw,
          padding: EdgeInsets.symmetric(horizontal: 16.cw),
          alignment: Alignment.center,
          child: Text(
            AppTexts.unblock,
            style: GoogleFonts.nunito(
              fontSize: 13.5.csp,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
