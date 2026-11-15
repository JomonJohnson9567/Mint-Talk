import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_icon_square.dart';
import 'package:mint_talk/features/shared/chat/domain/entities/conversation_entity.dart';

class HostChatListTile extends StatelessWidget {
  final ConversationEntity conversation;
  final String myUserId;
  final VoidCallback onTap;

  /// Position in the list — picks the alternating avatar tint.
  final int index;

  const HostChatListTile({
    super.key,
    required this.conversation,
    required this.myUserId,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final other = conversation.otherParticipant(myUserId);
    final unread = conversation.unreadCountFor(myUserId);
    final lastMessage = conversation.lastMessage?.content ?? 'Say hi 👋';
    final lastMessageAt = conversation.lastMessageAt;
    final radius = BorderRadius.circular(18.r);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.cw),
      child: Material(
        color: AppColors.cardWhite,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 14.cw),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: AppColors.profileDivider),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                _ContactAvatar(
                  name: other.fullName,
                  avatarUrl: other.avatarUrl,
                  tint: HostIconTint.alternating(index),
                ),
                SizedBox(width: 14.cw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        other.fullName.isNotEmpty ? other.fullName : 'User',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.csp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.plumDeep,
                        ),
                      ),
                      SizedBox(height: 4.cw),
                      Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.csp,
                          fontWeight: unread > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: unread > 0
                              ? AppColors.plumMuted
                              : AppColors.hostSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.cw),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (lastMessageAt != null)
                      Text(
                        _formatTime(lastMessageAt),
                        style: TextStyle(
                          fontSize: 11.5.csp,
                          color: AppColors.hostSubtitle,
                        ),
                      ),
                    SizedBox(height: 6.cw),
                    if (unread > 0)
                      _UnreadBadge(count: unread)
                    else
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 22.csp,
                        color: AppColors.hostSubtitle,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// `12:40 PM` today, `Yesterday`, otherwise `12 Oct`.
  static String _formatTime(DateTime time) {
    final local = time.toLocal();
    final today = DateUtils.dateOnly(DateTime.now());
    final daysAgo = today.difference(DateUtils.dateOnly(local)).inDays;
    if (daysAgo == 0) {
      final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
      final minute = local.minute.toString().padLeft(2, '0');
      final period = local.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }
    if (daysAgo == 1) return AppTexts.yesterday;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${local.day} ${months[local.month - 1]}';
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 22.cw),
      padding: EdgeInsets.symmetric(horizontal: 6.cw, vertical: 3.cw),
      decoration: BoxDecoration(
        color: AppColors.linkMagenta,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.csp,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final HostIconTint tint;

  const _ContactAvatar({
    required this.name,
    required this.avatarUrl,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl.startsWith('http');
    final size = 52.cw;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: tint.background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: hasImage
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                width: size,
                height: size,
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
        fontSize: 20.csp,
        fontWeight: FontWeight.w700,
        color: AppColors.plumDeep,
      ),
    );
  }
}
