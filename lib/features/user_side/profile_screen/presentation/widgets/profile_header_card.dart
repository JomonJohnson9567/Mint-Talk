import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/cubit/profile_info_cubit.dart';
import 'profile_avatar_skeleton.dart';

/// Lavender card with the user's avatar, name and the edit shortcut, with the
/// mascot faded in on the right.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.cw),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.videoCardBg, AppColors.cardWhite],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: 136.cw,
              child: const _FadedMascot(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.cw, 18.cw, 104.cw, 18.cw),
              child: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
                builder: (context, state) {
                  if (state.isLoading) return const ProfileAvatarSkeleton();
                  return Row(
                    children: [
                      _ProfileAvatar(
                        fullName: state.fullName,
                        imagePath: state.imagePath,
                      ),
                      SizedBox(width: 12.cw),
                      Expanded(
                        child: _ProfileDetails(fullName: state.fullName),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The mascot PNG has an opaque background, so its left edge is masked out
/// to melt into the card gradient.
class _FadedMascot extends StatelessWidget {
  const _FadedMascot();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColors.transparent, AppColors.black],
        stops: [0.0, 0.4],
      ).createShader(bounds),
      child: Image.asset(AppAssets.profileMascot, fit: BoxFit.cover),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.fullName, required this.imagePath});

  final String? fullName;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final name = fullName?.trim() ?? '';
    final initials = name.isEmpty
        ? 'U'
        : name
              .split(RegExp(r'\s+'))
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part[0].toUpperCase())
              .join();
    final imageProvider = _resolveImageProvider(imagePath ?? '');
    final size = 82.cw;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 3.cw),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: size / 2,
              backgroundColor: AppColors.primaryColor,
              backgroundImage: imageProvider,
              child: imageProvider != null
                  ? null
                  : Text(
                      initials,
                      style: GoogleFonts.nunito(
                        fontSize: 32.csp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
          Positioned(
            right: 2.cw,
            bottom: 4.cw,
            child: Container(
              width: 18.cw,
              height: 18.cw,
              decoration: BoxDecoration(
                color: AppColors.onlineIndicator,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 3.cw),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _resolveImageProvider(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }
    if (trimmed.startsWith('/uploads/')) {
      return NetworkImage('${ApiEndpoints.baseUrl}$trimmed');
    }
    if (File(trimmed).existsSync()) {
      return FileImage(File(trimmed));
    }
    if (trimmed.startsWith('assets/')) {
      return AssetImage(trimmed);
    }
    return null;
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.fullName});

  final String? fullName;

  @override
  Widget build(BuildContext context) {
    final displayName = fullName?.trim().isNotEmpty == true
        ? fullName!.trim()
        : 'User';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.nunito(
            fontSize: 20.csp,
            fontWeight: FontWeight.w800,
            color: AppColors.plumDeep,
          ),
        ),
        SizedBox(height: 2.cw),
        Text(
          AppTexts.profileTagline,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.csp,
            fontWeight: FontWeight.w500,
            color: AppColors.plumMuted,
            height: 1.3,
          ),
        ),
        SizedBox(height: 10.cw),
        const _EditProfileButton(),
      ],
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

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
        onTap: () async {
          final updated = await Navigator.pushNamed(
            context,
            AppRoutes.userProfileEditScreen,
          );
          if (updated == true && context.mounted) {
            context.read<ProfileInfoCubit>().loadProfileInfo();
          }
        },
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
              Flexible(
                child: Text(
                  AppTexts.editProfile,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.csp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.plumDeep,
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
