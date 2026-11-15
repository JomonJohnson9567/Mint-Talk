import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import '../cubit/blocked_users_cubit.dart';
import '../widgets/blocked_users_contents.dart';
import 'blocked_list_kind.dart';

/// Blocked list for both sides — "Blocked Hosts" for users, "Blocked Users"
/// for hosts.
class BlockedUsersScreen extends StatelessWidget {
  final BlockedListKind kind;

  const BlockedUsersScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BlockedUsersCubit>()..loadBlockedUsers(),
      child: Scaffold(
        backgroundColor: AppColors.rechargeBackground,
        appBar: CustomAppBar(
          title: kind.title,
          automaticallyImplyLeading: true,
          centerTitle: false,
          foregroundColor: AppColors.plumDeep,
        ),
        body: SafeArea(bottom: false, child: BlockedUsersContents(kind: kind)),
      ),
    );
  }
}
