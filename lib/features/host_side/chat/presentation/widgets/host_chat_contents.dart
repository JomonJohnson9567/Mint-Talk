import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/shared/chat/domain/entities/message_entity.dart';
import 'package:mint_talk/features/shared/chat/presentation/cubit/chat_thread_cubit.dart';
import 'package:mint_talk/features/shared/chat/presentation/cubit/chat_thread_state.dart';

class HostChatContents extends StatelessWidget {
  const HostChatContents({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatThreadCubit, ChatThreadState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF9FBFF), Color(0xFFEFF4FF)],
            ),
          ),
          child: Column(
            children: [
              _ChatHeader(
                name: state.recipientName,
                avatarUrl: state.recipientAvatarUrl,
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),
                      Expanded(child: _MessageTimeline(state: state)),
                      if (state.predefinedMessages.isNotEmpty)
                        _QuickMessageRail(
                          prompts: state.predefinedMessages
                              .map((m) => m.text)
                              .toList(),
                          onPromptTap: context
                              .read<ChatThreadCubit>()
                              .selectPrompt,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final String name;
  final String? avatarUrl;

  const _ChatHeader({required this.name, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 12.h,
        left: 20.w,
        right: 20.w,
        bottom: 18.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
        border: Border(bottom: BorderSide(color: AppColors.borderSoft)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primaryColor,
                size: 22.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          _HeaderAvatar(name: name, avatarUrl: avatarUrl),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;

  const _HeaderAvatar({required this.name, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl != null && avatarUrl!.startsWith('http');
    return Container(
      width: 46.w,
      height: 46.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, AppColors.tealBackground],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: hasImage
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl!,
                width: 46.w,
                height: 46.w,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => _InitialLetter(name: name),
              ),
            )
          : _InitialLetter(name: name),
    );
  }
}

class _InitialLetter extends StatelessWidget {
  final String name;

  const _InitialLetter({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      ),
    );
  }
}

class _MessageTimeline extends StatefulWidget {
  final ChatThreadState state;

  const _MessageTimeline({required this.state});

  @override
  State<_MessageTimeline> createState() => _MessageTimelineState();
}

class _MessageTimelineState extends State<_MessageTimeline> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _MessageTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.messages.length > oldWidget.state.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _onScroll() {
    if (_controller.position.pixels <= 100 &&
        widget.state.hasMoreMessages &&
        !widget.state.isLoadingMoreMessages) {
      context.read<ChatThreadCubit>().loadMoreMessages();
    }
  }

  void _scrollToBottom() {
    if (!_controller.hasClients) return;
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    if (state.status == ChatThreadStatus.loading && state.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (state.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            'Pick a quick reply below to start the conversation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.45,
              color: AppColors.subtitleText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () => context.read<ChatThreadCubit>().refreshMessages(),
      child: ListView.builder(
        controller: _controller,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        itemCount:
            state.messages.length + (state.isLoadingMoreMessages ? 1 : 0),
        itemBuilder: (context, index) {
          if (state.isLoadingMoreMessages && index == 0) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            );
          }
          final messageIndex = state.isLoadingMoreMessages ? index - 1 : index;
          final message = state.messages[messageIndex];
          return _MessageBubble(
            message: message,
            isMine: message.isMine(state.myUserId ?? ''),
            isSending: state.sendingClientMessageIds.contains(message.id),
            isFailed: state.failedClientMessageIds.contains(message.id),
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMine;
  final bool isSending;
  final bool isFailed;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.isSending,
    required this.isFailed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: isSending ? 0.6 : 1,
            child: Container(
              margin: EdgeInsets.only(bottom: 4.h),
              constraints: BoxConstraints(maxWidth: 0.78.sw),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isMine ? AppColors.primaryColor : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(isMine ? 18.r : 6.r),
                  bottomRight: Radius.circular(isMine ? 6.r : 18.r),
                ),
                border: Border.all(
                  color: isMine ? AppColors.primaryColor : AppColors.borderSoft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 15.sp,
                  height: 1.35,
                  color: isMine ? AppColors.white : AppColors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (isFailed)
            GestureDetector(
              onTap: () =>
                  context.read<ChatThreadCubit>().retryMessage(message.id),
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 13.sp, color: AppColors.red),
                    SizedBox(width: 4.w),
                    Text(
                      'Failed — tap to retry',
                      style: TextStyle(fontSize: 11.sp, color: AppColors.red),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

class _QuickMessageRail extends StatelessWidget {
  final List<String> prompts;
  final ValueChanged<int> onPromptTap;

  const _QuickMessageRail({required this.prompts, required this.onPromptTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: AppColors.borderSoft)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppTexts.quickMessages,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.subtitleText,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 48.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: prompts.length,
              separatorBuilder: (context, index) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => onPromptTap(index),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.softBlue,
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(color: AppColors.borderSoft),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      prompts[index],
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
