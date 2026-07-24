import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/shared/block_users/presentation/cubit/blocked_users_cubit.dart';
import 'package:mint_talk/features/host_side/block_users/presentation/widgets/blocked_users_contents.dart';

class BlockedUsers extends StatelessWidget {
  const BlockedUsers({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BlockedUsersCubit>()..loadBlockedUsers(),
      child: const _BlockedUsersView(),
    );
  }
}

class _BlockedUsersView extends StatelessWidget {
  const _BlockedUsersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Blocked Users',
        automaticallyImplyLeading: true,
      ),
      body: const BlockedUsersContents(),
    );
  }
}
