// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/confirmation_dialog.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/domain/models/host_call_log_entry_model.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/presentation/cubit/host_call_log_cubit.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/presentation/cubit/host_call_log_state.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/presentation/widgets/host_call_log_filter_tabs.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/presentation/widgets/host_call_log_item.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/presentation/widgets/host_call_log_search_bar.dart';

class HostCallLogContents extends StatelessWidget {
  final HostCallFilterType selectedFilter;
  final ValueChanged<HostCallFilterType> onFilterChanged;

  const HostCallLogContents({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  List<HostCallLogEntryModel> _applyFilter(
    List<HostCallLogEntryModel> entries,
    HostCallFilterType filter,
  ) {
    return entries
        .where((e) =>
            filter == HostCallFilterType.video ? e.isVideoCall : !e.isVideoCall)
        .toList();
  }

  void _showBlockDialog(
    BuildContext context,
    HostCallLogEntryModel entry,
  ) {
    final cubit = context.read<HostCallLogCubit>();
    final isBlocked = entry.isBlocked;

    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        icon: Icons.block_rounded,
        iconColor: AppColors.red,
        accentColor: AppColors.red,
        title: isBlocked ? 'Unblock ${entry.name}?' : 'Block ${entry.name}?',
        content: isBlocked
            ? '${entry.name} will be able to call you again after unblocking.'
            : 'Blocking ${entry.name} will prevent them from calling you. You can unblock anytime.',
        confirmButtonText: isBlocked ? 'Unblock' : 'Block',
        cancelButtonText: 'Cancel',
        onConfirm: () {
          Navigator.pop(context);
          cubit.blockUser(entry.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: const HostCallLogSearchBar(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: HostCallLogFilterTabs(
            selectedFilter: selectedFilter,
            onFilterChanged: onFilterChanged,
          ),
        ),
        SizedBox(height: 12.h),
        Expanded(
          child: BlocBuilder<HostCallLogCubit, HostCallLogState>(
            builder: (context, state) {
              if (state is HostCallLogLoaded) {
                final filtered = _applyFilter(state.entries, selectedFilter);

                return RefreshIndicator(
                  onRefresh: () async {
                    await context.read<HostCallLogCubit>().loadCallLogs();
                  },
                  child: filtered.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _EmptyCallLog(filter: selectedFilter),
                          ),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(top: 4.h, bottom: 100.h),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final entry = filtered[index];
                            return HostCallLogItem(
                              userId: entry.id,
                              name: entry.name,
                              imageUrl: entry.imageUrl,
                              duration: entry.duration,
                              isVideoCall: entry.isVideoCall,
                              isBlocked: entry.isBlocked,
                              onBlockTap: () => _showBlockDialog(context, entry),
                            );
                          },
                        ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyCallLog extends StatelessWidget {
  final HostCallFilterType filter;

  const _EmptyCallLog({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            filter == HostCallFilterType.video
                ? Icons.videocam_off_outlined
                : Icons.phone_disabled_outlined,
            size: 56.sp,
            color: AppColors.subtitleText.withAlpha(100),
          ),
          SizedBox(height: 16.h),
          Text(
            'No ${filter == HostCallFilterType.video ? 'video' : 'audio'} call logs yet',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.subtitleText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
