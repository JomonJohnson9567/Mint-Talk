import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/home_user_entity.dart';
import 'package:mint_talk/features/user_side/host_profile_screen/presentation/widgets/screen_contents.dart'
    as host_profile;

class HostProfileScreen extends StatelessWidget {
  final HomeUserEntity user;

  const HostProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppTexts.profileDetails,
        automaticallyImplyLeading: true,
      ),
      body: host_profile.ScreenContents(user: user),
    );
  }
}
