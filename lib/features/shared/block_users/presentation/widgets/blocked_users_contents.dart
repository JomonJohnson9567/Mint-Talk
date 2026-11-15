import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/confirmation_dialog.dart';
import '../../domain/entities/blocked_user_entity.dart';
import '../cubit/blocked_users_cubit.dart';
import '../cubit/blocked_users_state.dart';
import '../screen/blocked_list_kind.dart';
import 'blocked_user_tile.dart';
import 'blocked_users_empty_state.dart';
import 'blocked_users_skeleton.dart';

class BlockedUsersContents extends StatelessWidget {
  final BlockedListKind kind;

  const BlockedUsersContents({super.key, required this.kind});

  /// Same cap as the recharge / call log screens so tablets get a centred
  /// column.
  static const double _contentWidth = 760.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = math.max(
          16.cw,
          (constraints.maxWidth - _contentWidth) / 2,
        );

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () => context.read<BlockedUsersCubit>().loadBlockedUsers(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  4.cw,
                  horizontalPadding,
                  0,
                ),
                sliver: _BlockedListBody(kind: kind),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 32.cw)),
            ],
          ),
        );
      },
    );
  }
}

class _BlockedListBody extends StatelessWidget {
  final BlockedListKind kind;

  const _BlockedListBody({required this.kind});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BlockedUsersCubit, BlockedUsersState>(
      listener: (context, state) {
        if (state is BlockedUsersLoaded && state.actionMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionMessage!),
              backgroundColor: AppColors.green,
            ),
          );
        } else if (state is BlockedUsersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      // A failed unblock emits an error and then restores the list; skip
      // the error frame so the list doesn't flash away.
      buildWhen: (previous, current) =>
          !(current is BlockedUsersError && previous is BlockedUsersLoaded),
      builder: (context, state) {
        return switch (state) {
          BlockedUsersInitial() || BlockedUsersLoading() =>
            const SliverToBoxAdapter(child: BlockedUsersSkeleton()),
          BlockedUsersError(:final message) => SliverToBoxAdapter(
            child: BlockedUsersEmptyState.failure(
              message: message,
              onRetry: () =>
                  context.read<BlockedUsersCubit>().loadBlockedUsers(),
            ),
          ),
          BlockedUsersLoaded(:final users) when users.isEmpty =>
            SliverToBoxAdapter(child: BlockedUsersEmptyState.none(kind: kind)),
          BlockedUsersLoaded(:final users) => SliverList.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final name = _displayName(user);
              return BlockedUserTile(
                user: user,
                name: name,
                showDivider: index < users.length - 1,
                onUnblock: () => _confirmUnblock(context, user, name),
              );
            },
          ),
        };
      },
    );
  }

  String _displayName(BlockedUserEntity user) =>
      user.fullName.isNotEmpty ? user.fullName : kind.fallbackName;

  void _confirmUnblock(
    BuildContext context,
    BlockedUserEntity user,
    String name,
  ) {
    final cubit = context.read<BlockedUsersCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        icon: Icons.lock_open_rounded,
        iconColor: AppColors.primaryColor,
        accentColor: AppColors.primaryColor,
        title: kind.unblockTitle(name),
        content: kind.unblockMessage(name),
        confirmButtonText: AppTexts.unblock,
        onConfirm: () {
          Navigator.pop(dialogContext);
          cubit.unblockUser(
            user.blockedId.isNotEmpty ? user.blockedId : user.id,
          );
        },
      ),
    );
  }
}
