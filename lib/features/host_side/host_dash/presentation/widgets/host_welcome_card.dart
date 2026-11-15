import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/host_dash_cubit.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_cubit.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_state.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/screen/host_profile_screen.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_avatar.dart';

/// Avatar + name row under the header; tapping it opens the host profile.
class HostWelcomeCard extends StatelessWidget {
  final HostProfileState profile;

  const HostWelcomeCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 4.cw),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => openHostProfile(context),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.cw),
            child: Row(
              children: [
                Container(
                  width: 68.cw,
                  height: 68.cw,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.hostAvatarBg,
                  ),
                  padding: EdgeInsets.all(3.cw),
                  child: ClipOval(
                    child: HostProfileAvatar(
                      imagePath: profile.imagePath ?? '',
                      initials: profile.initials,
                      size: 62,
                    ),
                  ),
                ),
                SizedBox(width: 14.cw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.csp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.plumDeep,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.cw),
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.primaryColor,
                            size: 18.csp,
                          ),
                        ],
                      ),
                      SizedBox(height: 2.cw),
                      Text(
                        AppTexts.verifiedHost,
                        style: TextStyle(
                          fontSize: 12.csp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.hostSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Refreshes the profile, then opens [HostProfileScreen] on the same cubit.
/// [HostDashCubit] is passed along too — the pushed route sits above the
/// host navigation providers, and the rate tiles read live status from it.
Future<void> openHostProfile(BuildContext context) async {
  final profileCubit = context.read<HostProfileCubit>();
  final dashCubit = context.read<HostDashCubit>();
  await profileCubit.loadProfile();
  if (!context.mounted) return;
  await Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: profileCubit),
          BlocProvider.value(value: dashCubit),
        ],
        child: const HostProfileScreen(),
      ),
    ),
  );
}
