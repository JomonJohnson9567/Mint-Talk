import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/chat/presentation/screen/host_chat_screen.dart';
import 'package:mint_talk/features/host_side/chat/presentation/widgets/host_chat_list_tile.dart';
import 'package:mint_talk/features/shared/chat/presentation/cubit/conversations_cubit.dart';
import 'package:mint_talk/features/shared/chat/presentation/cubit/conversations_state.dart';

class HostChatListContents extends StatelessWidget {
  const HostChatListContents({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationsCubit, ConversationsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (state.status == ConversationsStatus.failure &&
            state.conversations.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.errorMessage ?? 'Failed to load conversations',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.red, fontSize: 14.sp),
                  ),
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: () =>
                        context.read<ConversationsCubit>().loadConversations(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final myUserId = state.myUserId ?? '';

        if (state.conversations.isEmpty) {
          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () =>
                context.read<ConversationsCubit>().loadConversations(),
            child: ListView(
              children: [
                SizedBox(height: 160.h),
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 56.sp,
                  color: AppColors.subtitleText.withAlpha(100),
                ),
                SizedBox(height: 16.h),
                Center(
                  child: Text(
                    'No conversations yet',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.subtitleText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Center(
                  child: Text(
                    'Tap the + to message someone.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.subtitleText,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () =>
              context.read<ConversationsCubit>().loadConversations(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
                context.read<ConversationsCubit>().loadMore();
              }
              return false;
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                final other = conversation.otherParticipant(myUserId);
                return HostChatListTile(
                  conversation: conversation,
                  myUserId: myUserId,
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
            ),
          ),
        );
      },
    );
  }
}
