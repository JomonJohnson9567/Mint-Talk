import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/chat/presentation/bloc/user_chat_cubit.dart';

class UserChatContents extends StatelessWidget {
  const UserChatContents({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserChatCubit, UserChatState>(
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
              _ChatHeader(hostName: state.hostName),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),
                      Expanded(
                        child: _SentMessageTimeline(
                          messages: state.sentMessages,
                        ),
                      ),
                      _QuickMessageRail(
                        prompts: state.quickPrompts,
                        selectedIndex: state.selectedPromptIndex,
                        onPromptTap: context.read<UserChatCubit>().selectPrompt,
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
  final String hostName;

  const _ChatHeader({required this.hostName});

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
        border: Border(
          bottom: BorderSide(color: AppColors.borderSoft),
        ),
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
          Container(
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
            child: Text(
              hostName.isNotEmpty ? hostName[0].toUpperCase() : 'H',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hostName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: AppColors.onlineIndicator,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      AppTexts.onlineNow,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.subtitleText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: AppColors.softMint,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Icon(
              Icons.call_rounded,
              color: AppColors.primaryColor,
              size: 22.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _SentMessageTimeline extends StatelessWidget {
  final List<ChatMessage> messages;

  const _SentMessageTimeline({required this.messages});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            'Pick a quick message below to start the conversation.',
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

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return _SentMessageBubble(message: messages[index]);
      },
    );
  }
}

class _SentMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _SentMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(18.r),
            bottomRight: Radius.circular(6.r),
          ),
          border: Border.all(color: AppColors.primaryColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 15.sp,
            height: 1.35,
            color: AppColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _QuickMessageRail extends StatelessWidget {
  final List<String> prompts;
  final int? selectedIndex;
  final ValueChanged<int> onPromptTap;

  const _QuickMessageRail({
    required this.prompts,
    required this.selectedIndex,
    required this.onPromptTap,
  });

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
                final selected = selectedIndex == index;
                return GestureDetector(
                  onTap: () => onPromptTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(
                              colors: [
                                AppColors.primaryColor,
                                AppColors.tealBackground,
                              ],
                            )
                          : null,
                      color: selected ? null : AppColors.softBlue,
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryColor
                            : AppColors.borderSoft,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      prompts[index],
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.white : AppColors.black,
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
