import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import '../cubit/notifications_cubit.dart';

/// All / Unread filter pills; the Unread pill carries the live unread count.
class NotificationFilterPills extends StatelessWidget {
  final bool unreadOnly;
  final ValueChanged<bool> onChanged;

  const NotificationFilterPills({
    super.key,
    required this.unreadOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.select<NotificationsCubit, int>(
      (cubit) => cubit.state.unreadCount,
    );
    final unreadLabel = unreadCount > 0
        ? '${AppTexts.filterUnread} · ${unreadCount > 99 ? '99+' : unreadCount}'
        : AppTexts.filterUnread;

    return Row(
      children: [
        Expanded(
          child: _Pill(
            label: AppTexts.filterAll,
            isSelected: !unreadOnly,
            onTap: () => onChanged(false),
          ),
        ),
        SizedBox(width: 10.cw),
        Expanded(
          child: _Pill(
            label: unreadLabel,
            isSelected: unreadOnly,
            onTap: () => onChanged(true),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24.cw);

    return Material(
      color: isSelected ? AppColors.primaryColor : AppColors.audioBtnBg,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: SizedBox(
          height: 44.cw,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.5.csp,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.white : AppColors.plumDeep,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
