import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/widgets/host_welcome_card.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_cubit.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_avatar.dart';

/// Avatar, name and "Edit profile" link at the top of host settings; tapping
/// the card opens the host profile.
class HostSettingsProfileCard extends StatelessWidget {
  const HostSettingsProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context
        .select<
          HostProfileCubit,
          ({String name, String image, String initials})
        >(
          (cubit) => (
            name: cubit.state.displayName,
            image: cubit.state.imagePath ?? '',
            initials: cubit.state.initials,
          ),
        );
    final radius = BorderRadius.circular(20.r);

    return Material(
      // The mascot image is opaque — its background matches hostPromoBanner.
      color: AppColors.hostPromoBanner,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openHostProfile(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.cw, 16.cw, 12.cw, 16.cw),
              child: _AvatarWithBadge(
                imagePath: profile.image,
                initials: profile.initials,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.cw),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.csp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.plumDeep,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2.cw),
                    Text(
                      AppTexts.verifiedHost,
                      style: TextStyle(
                        fontSize: 12.5.csp,
                        color: AppColors.hostSubtitle,
                      ),
                    ),
                    SizedBox(height: 10.cw),
                    const _EditProfileLink(),
                  ],
                ),
              ),
            ),
            Image.asset(
              AppAssets.hostEarnMascot,
              height: 92.cw,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarWithBadge extends StatelessWidget {
  final String imagePath;
  final String initials;

  const _AvatarWithBadge({required this.imagePath, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 72.cw,
          height: 72.cw,
          padding: EdgeInsets.all(3.cw),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
          ),
          child: ClipOval(
            child: HostProfileAvatar(
              imagePath: imagePath,
              initials: initials,
              size: 66,
            ),
          ),
        ),
        Positioned(
          right: -2.cw,
          bottom: -2.cw,
          child: Container(
            width: 24.cw,
            height: 24.cw,
            decoration: BoxDecoration(
              color: AppColors.hostVideoAccent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 2.cw),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 13.csp,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditProfileLink extends StatelessWidget {
  const _EditProfileLink();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final profileCubit = context.read<HostProfileCubit>();
        await getIt<NavigationService>().navigateTo(
          AppRoutes.hostProfileEditScreen,
        );
        // Pick up any edits once the user comes back.
        profileCubit.loadProfile();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppTexts.editProfile,
            style: TextStyle(
              fontSize: 13.csp,
              fontWeight: FontWeight.w700,
              color: AppColors.plumDeep,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.plumDeep,
            ),
          ),
          SizedBox(width: 4.cw),
          Icon(
            Icons.arrow_forward_rounded,
            size: 15.csp,
            color: AppColors.plumDeep,
          ),
        ],
      ),
    );
  }
}
