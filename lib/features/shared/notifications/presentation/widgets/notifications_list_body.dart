import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/shared/notifications/domain/entities/notification_entity.dart';
import 'notification_filter_pills.dart';
import 'notification_tile.dart';
import 'notifications_empty_state.dart';
import 'notifications_skeleton.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';

class NotificationsListBody extends StatefulWidget {
  /// Scrolls above the filter (e.g. a banner). None by default.
  final Widget? header;

  /// Replaces the default [NotificationFilterPills].
  final Widget Function(bool unreadOnly, ValueChanged<bool> onChanged)?
  filterBuilder;

  const NotificationsListBody({super.key, this.header, this.filterBuilder});

  @override
  State<NotificationsListBody> createState() => _NotificationsListBodyState();
}

class _NotificationsListBodyState extends State<NotificationsListBody> {
  /// Same cap as the recharge / call log screens so tablets get a centred
  /// column.
  static const double _contentWidth = 760.0;

  /// Screen-local: the cubit is app-wide (it also drives the bell badge), so
  /// the filter shouldn't outlive this screen.
  bool _unreadOnly = false;

  void _setUnreadOnly(bool value) => setState(() => _unreadOnly = value);

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
          onRefresh: () =>
              context.read<NotificationsCubit>().loadNotifications(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
                context.read<NotificationsCubit>().loadMore();
              }
              return false;
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                if (widget.header != null)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      4.cw,
                      horizontalPadding,
                      12.cw,
                    ),
                    sliver: SliverToBoxAdapter(child: widget.header),
                  ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    widget.header == null ? 4.cw : 0,
                    horizontalPadding,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child:
                        widget.filterBuilder?.call(
                          _unreadOnly,
                          _setUnreadOnly,
                        ) ??
                        NotificationFilterPills(
                          unreadOnly: _unreadOnly,
                          onChanged: _setUnreadOnly,
                        ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: _NotificationsBody(unreadOnly: _unreadOnly),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 32.cw)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  final bool unreadOnly;

  const _NotificationsBody({required this.unreadOnly});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        if (state.isLoading && state.notifications.isEmpty) {
          return const SliverToBoxAdapter(child: NotificationsSkeleton());
        }

        if (state.status == NotificationsStatus.failure &&
            state.notifications.isEmpty) {
          return SliverToBoxAdapter(
            child: NotificationsEmptyState.failure(
              message: state.errorMessage ?? AppTexts.unableToLoadNotifications,
              onRetry: () =>
                  context.read<NotificationsCubit>().loadNotifications(),
            ),
          );
        }

        if (state.notifications.isEmpty) {
          return const SliverToBoxAdapter(
            child: NotificationsEmptyState.none(),
          );
        }

        final visible = unreadOnly
            ? state.notifications.where((n) => !n.isRead).toList()
            : state.notifications;
        if (visible.isEmpty && (state.unreadCount == 0 || !state.hasMore)) {
          return const SliverToBoxAdapter(
            child: NotificationsEmptyState.allCaughtUp(),
          );
        }

        final rows = _groupByDay(visible);
        final showLoader = state.hasMore;

        return SliverList.builder(
          itemCount: rows.length + (showLoader ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= rows.length) return const _LoadMoreIndicator();
            return switch (rows[index]) {
              _SectionRow(:final label) => _SectionLabel(label: label),
              _EntryRow(:final notification, :final showDivider) =>
                NotificationTile(
                  notification: notification,
                  showDivider: showDivider,
                  onTap: () => context.read<NotificationsCubit>().markAsRead(
                    notification.id,
                  ),
                ),
            };
          },
        );
      },
    );
  }

  /// Flattens the (newest-first) notifications into section labels + rows,
  /// starting a new section whenever the local calendar day changes.
  static List<_Row> _groupByDay(List<NotificationEntity> notifications) {
    final rows = <_Row>[];
    String? currentLabel;
    for (var i = 0; i < notifications.length; i++) {
      final label = _dayLabel(notifications[i].createdAt);
      if (label != currentLabel) {
        rows.add(_SectionRow(label));
        currentLabel = label;
      }
      final isLastInSection =
          i == notifications.length - 1 ||
          _dayLabel(notifications[i + 1].createdAt) != label;
      rows.add(_EntryRow(notifications[i], showDivider: !isLastInSection));
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
  static String _dayLabel(DateTime time) {
    final today = DateUtils.dateOnly(DateTime.now());
    final day = DateUtils.dateOnly(time.toLocal());
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
  final NotificationEntity notification;
  final bool showDivider;

  const _EntryRow(this.notification, {required this.showDivider});
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

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.cw),
      child: Center(
        child: SizedBox(
          width: 24.cw,
          height: 24.cw,
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
