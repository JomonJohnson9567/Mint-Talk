import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/bloc/call_log_cubit.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/bloc/call_log_state.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/widgets/call_log_empty_state.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/widgets/call_log_hero_card.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/widgets/call_log_item.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/widgets/call_log_search_bar.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/widgets/call_log_skeleton.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/widgets/call_log_type_pills.dart';

class CallLogContents extends StatelessWidget {
  const CallLogContents({super.key});

  /// Same cap as the recharge screens so tablets get a centred column.
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
          onRefresh: () => context.read<CallLogCubit>().loadCallLogs(),
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
                sliver: const SliverToBoxAdapter(child: _Header()),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: const _CallLogBody(),
              ),
              // Clears the floating bottom nav bar.
              SliverToBoxAdapter(child: SizedBox(height: 110.cw)),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CallLogHeroCard(),
        SizedBox(height: 14.cw),
        const CallLogSearchBar(),
        SizedBox(height: 14.cw),
        const CallLogTypePills(),
      ],
    );
  }
}

class _CallLogBody extends StatelessWidget {
  const _CallLogBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallLogCubit, CallLogState>(
      builder: (context, state) {
        if (state.isLoading && state.callLogs.isEmpty) {
          return const SliverToBoxAdapter(child: CallLogSkeleton());
        }

        if (state.status == CallLogStatus.failure && state.callLogs.isEmpty) {
          return SliverToBoxAdapter(
            child: CallLogEmptyState.failure(
              message: state.errorMessage ?? AppTexts.unableToLoadCalls,
              onAction: () => context.read<CallLogCubit>().loadCallLogs(),
            ),
          );
        }

        if (state.callLogs.isEmpty) {
          return SliverToBoxAdapter(child: CallLogEmptyState.noCalls(context));
        }

        final rows = _groupByDay(state.visibleLogs);
        if (rows.isEmpty) {
          return const SliverToBoxAdapter(child: CallLogEmptyState.noMatches());
        }

        return SliverList.builder(
          itemCount: rows.length,
          itemBuilder: (context, index) => switch (rows[index]) {
            _SectionRow(:final label) => _SectionLabel(label: label),
            _EntryRow(:final entry, :final showDivider) => CallLogItem(
              entry: entry,
              showDivider: showDivider,
            ),
          },
        );
      },
    );
  }

  /// Flattens the (newest-first) logs into section labels + rows, starting a
  /// new section whenever the local calendar day changes.
  static List<_Row> _groupByDay(List<CallLogEntry> logs) {
    final rows = <_Row>[];
    String? currentLabel;
    for (var i = 0; i < logs.length; i++) {
      final label = _dayLabel(logs[i].createdAt);
      if (label != currentLabel) {
        rows.add(_SectionRow(label));
        currentLabel = label;
      }
      final isLastInSection =
          i == logs.length - 1 || _dayLabel(logs[i + 1].createdAt) != label;
      rows.add(_EntryRow(logs[i], showDivider: !isLastInSection));
    }
    return rows;
  }

  static const _months = [
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

  /// `Today`, `Yesterday`, `12 Oct`, or `12 Oct 2025` for earlier years.
  static String _dayLabel(DateTime? time) {
    if (time == null) return AppTexts.earlier;
    final today = DateUtils.dateOnly(DateTime.now());
    final day = DateUtils.dateOnly(time);
    final daysAgo = today.difference(day).inDays;
    if (daysAgo == 0) return AppTexts.today;
    if (daysAgo == 1) return AppTexts.yesterday;
    final dayMonth = '${day.day} ${_months[day.month - 1]}';
    return day.year == today.year ? dayMonth : '$dayMonth ${day.year}';
  }
}

sealed class _Row {
  const _Row();
}

class _SectionRow extends _Row {
  final String label;

  const _SectionRow(this.label);
}

class _EntryRow extends _Row {
  final CallLogEntry entry;
  final bool showDivider;

  const _EntryRow(this.entry, {required this.showDivider});
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.cw, bottom: 4.cw),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 18.csp,
          fontWeight: FontWeight.w800,
          color: AppColors.plumDeep,
        ),
      ),
    );
  }
}
