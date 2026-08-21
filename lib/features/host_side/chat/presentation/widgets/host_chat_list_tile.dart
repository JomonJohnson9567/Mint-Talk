import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/shared/chat/domain/entities/conversation_entity.dart';

class HostChatListTile extends StatelessWidget {
  final ConversationEntity conversation;
  final String myUserId;
  final VoidCallback onTap;

  const HostChatListTile({
    super.key,
    required this.conversation,
    required this.myUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final other = conversation.otherParticipant(myUserId);
    final unread = conversation.unreadCountFor(myUserId);
    final lastMessage = conversation.lastMessage?.content ?? 'Say hi 👋';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Row(
          children: [
            _ContactAvatar(name: other.fullName, avatarUrl: other.avatarUrl),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    other.fullName.isNotEmpty ? other.fullName : 'User',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: unread > 0
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: unread > 0
                          ? AppColors.black
                          : AppColors.subtitleText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            if (unread > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: AppColors.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  final String name;
  final String avatarUrl;

  const _ContactAvatar({required this.name, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl.startsWith('http');
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, AppColors.tealBackground],
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: hasImage
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                width: 50.w,
                height: 50.w,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => _Initial(name: name),
              ),
            )
          : _Initial(name: name),
    );
  }
}

class _Initial extends StatelessWidget {
  final String name;

  const _Initial({required this.name});

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
