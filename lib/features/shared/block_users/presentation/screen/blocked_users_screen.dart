import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import '../cubit/blocked_users_cubit.dart';
import '../widgets/blocked_users_contents.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BlockedUsersCubit>()..loadBlockedUsers(),
      child: const Scaffold(
        backgroundColor: AppColors.white,
        appBar: CustomAppBar(
          title: 'Blocked Users',
          automaticallyImplyLeading: true,
        ),
        body: BlockedUsersContents(),
      ),
    );
  }
}
