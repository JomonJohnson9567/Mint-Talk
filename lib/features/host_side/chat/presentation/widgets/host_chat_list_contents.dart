import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/host_side/chat/presentation/screen/host_chat_screen.dart';
import 'package:mint_talk/features/host_side/chat/presentation/widgets/host_chat_list_tile.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_mascot_banner.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_segmented_toggle.dart';
import 'package:mint_talk/features/shared/chat/domain/entities/conversation_entity.dart';
import 'package:mint_talk/features/shared/chat/presentation/cubit/conversations_cubit.dart';
import 'package:mint_talk/features/shared/chat/presentation/cubit/conversations_state.dart';

class HostChatListContents extends StatefulWidget {
  const HostChatListContents({super.key});

  @override
  State<HostChatListContents> createState() => _HostChatListContentsState();
}

class _HostChatListContentsState extends State<HostChatListContents> {
  /// Screen-local filters over the already-loaded conversations.
  String _query = '';
  bool _unreadOnly = false;

  List<ConversationEntity> _visible(ConversationsState state) {
    final myUserId = state.myUserId ?? '';
    final query = _query.trim().toLowerCase();
    return state.conversations.where((conversation) {
      if (_unreadOnly && conversation.unreadCountFor(myUserId) == 0) {
        return false;
      }
      if (query.isEmpty) return true;
      return conversation
          .otherParticipant(myUserId)
          .fullName
          .toLowerCase()
          .contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.symmetric(horizontal: 16.cw);

    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () => context.read<ConversationsCubit>().loadConversations(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
            context.read<ConversationsCubit>().loadMore();
          }
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: padding.copyWith(top: 4.cw),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    const HostMascotBanner(
                      title: AppTexts.keepConversationGoing,
                      subtitle: AppTexts.littleMessageDifference,
                      mascotAsset: AppAssets.hostWaitingMascot,
                      // The waiting mascot is opaque on this lavender.
                      backgroundColor: AppColors.hostWaitingCard,
                    ),
                    SizedBox(height: 14.cw),
                    _SearchField(
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    SizedBox(height: 12.cw),
                    HostSegmentedToggle(
                      labels: const [AppTexts.filterAll, AppTexts.filterUnread],
                      selectedIndex: _unreadOnly ? 1 : 0,
                      onChanged: (index) =>
                          setState(() => _unreadOnly = index == 1),
                    ),
                    SizedBox(height: 8.cw),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: padding,
              sliver: BlocBuilder<ConversationsCubit, ConversationsState>(
                builder: (context, state) => _buildList(context, state),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 24),
              sliver: SliverToBoxAdapter(child: _ConversationsFooter()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, ConversationsState state) {
    if (state.isLoading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.cw),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        ),
      );
    }

    if (state.status == ConversationsStatus.failure &&
        state.conversations.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.cw),
          child: Column(
            children: [
              Text(
                state.errorMessage ?? 'Failed to load conversations',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.plumMuted, fontSize: 14.csp),
              ),
              SizedBox(height: 8.cw),
              TextButton(
                onPressed: () =>
                    context.read<ConversationsCubit>().loadConversations(),
                child: Text(
                  AppTexts.retry,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.csp,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final myUserId = state.myUserId ?? '';
    final visible = _visible(state);

    return SliverList.builder(
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final conversation = visible[index];
        final other = conversation.otherParticipant(myUserId);
        return HostChatListTile(
          conversation: conversation,
          myUserId: myUserId,
          index: index,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => HostChatScreen(
                args: HostChatArgs(
                  recipientId: other.id,
                  recipientName: other.fullName,
                  recipientAvatarUrl: other.avatarUrl,
                  conversationId: conversation.id,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.r),
      borderSide: const BorderSide(color: AppColors.lavenderBorder),
    );

    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: TextStyle(fontSize: 14.5.csp, color: AppColors.plumDeep),
      decoration: InputDecoration(
        hintText: AppTexts.searchConversations,
        hintStyle: TextStyle(fontSize: 14.5.csp, color: AppColors.hostSubtitle),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.hostSubtitle,
          size: 22.csp,
        ),
        filled: true,
        fillColor: AppColors.cardWhite,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 14.cw),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.hostVideoAccent),
        ),
      ),
    );
  }
}

/// Mascot + hint under the list; doubles as the empty state.
class _ConversationsFooter extends StatelessWidget {
  const _ConversationsFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.cw, 20.cw, 16.cw, 0),
      child: Column(
        children: [
          Container(
            width: 220.cw,
            decoration: BoxDecoration(
              // The waiting mascot is opaque on this lavender.
              color: AppColors.hostWaitingCard,
              borderRadius: BorderRadius.circular(110.cw),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(AppAssets.hostWaitingMascot, fit: BoxFit.cover),
          ),
          SizedBox(height: 14.cw),
          Text(
            AppTexts.connectWithPeopleSpoken,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5.csp, color: AppColors.hostSubtitle),
          ),
        ],
      ),
    );
  }
}
