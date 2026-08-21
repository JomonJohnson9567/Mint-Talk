import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/features/shared/block_users/presentation/cubit/blocked_users_cubit.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
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
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: AppTexts.profileDetails,
          automaticallyImplyLeading: true,
        ),
        body: host_profile.ScreenContents(host: host),
      ),
    );
  }
}
