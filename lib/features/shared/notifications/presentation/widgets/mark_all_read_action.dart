import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import '../cubit/notifications_cubit.dart';

/// App-bar action that marks every notification read; hidden once nothing is
/// unread.
class MarkAllReadAction extends StatelessWidget {
  const MarkAllReadAction({super.key});

  @override
  Widget build(BuildContext context) {
    final hasUnread = context.select<NotificationsCubit, bool>(
      (cubit) => cubit.state.unreadCount > 0,
    );

    if (!hasUnread) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(right: 6.cw),
      child: TextButton.icon(
        onPressed: () => context.read<NotificationsCubit>().markAllAsRead(),
        style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
        icon: Icon(Icons.done_all_rounded, size: 18.csp),
        label: Text(
          AppTexts.markAllRead,
          style: GoogleFonts.nunito(
            fontSize: 13.5.csp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
