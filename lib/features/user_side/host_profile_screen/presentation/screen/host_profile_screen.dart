import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/shared/block_users/presentation/cubit/blocked_users_cubit.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
import 'package:mint_talk/features/user_side/host_profile_screen/presentation/widgets/host_profile_background.dart';
import 'package:mint_talk/features/user_side/host_profile_screen/presentation/widgets/screen_contents.dart'
    as host_profile;

class HostProfileScreen extends StatelessWidget {
  final HostEntity host;

  const HostProfileScreen({super.key, required this.host});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BlockedUsersCubit>()..loadBlockedUsers(),
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: Stack(
          children: [
            const Positioned.fill(child: HostProfileBackground()),
            SafeArea(
              bottom: false,
              child: host_profile.ScreenContents(host: host),
            ),
          ],
        ),
      ),
    );
  }
}
