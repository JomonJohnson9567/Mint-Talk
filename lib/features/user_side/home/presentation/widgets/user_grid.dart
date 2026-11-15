import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/shared/system_config/presentation/cubit/system_config_cubit.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import 'home_skeleton.dart';
import 'host_layout_morph.dart';

/// Shared grid metrics so [HomeSkeleton] lines up exactly with real cards.
///
/// The photo keeps a fixed aspect ratio and everything below it is sized in
/// width-based units, so the card height derives from its width rather than
/// `.h` — on short phones `.h` shrinks faster than the text and buttons.
const double kHostPhotoAspectRatio = 1 / 0.92;

double hostCardExtent(double cardWidth) =>
    cardWidth / kHostPhotoAspectRatio + 90.cw;

double hostCardWidth(double gridWidth, int crossAxisCount, double spacing) =>
    (gridWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;

/// List-layout tile metrics, in `.cw` units, shared with [HomeSkeleton].
const double kHostTileAvatar = 56;
const double kHostTilePadding = 10;

double hostTileExtent() => (kHostTileAvatar + kHostTilePadding * 2).cw;

int hostGridCrossAxisCount(double width) {
  if (width >= 1200) return 6;
  if (width >= 900) return 5;
  if (width >= 600) return 4;
  return 3;
}

/// Two list columns on tablets so tiles aren't stretched across the screen.
int hostListCrossAxisCount(double width) => width >= 600 ? 2 : 1;

/// Scrollable host grid. On the home page, [header] (greeting, call cards,
/// tabs) and a section title scroll away with the grid, so it isn't squeezed
/// into whatever height is left on small phones. Without a header (the
/// online-users screens) only the grid is shown.
class UserGrid extends StatelessWidget {
  final Widget? header;

  /// Replaces the default per-tab section title shown under [header].
  final Widget Function(HomeTab tab)? sectionTitleBuilder;

  /// When set, cards offer a single call button of this type instead of
  /// both video and audio.
  final CallType? callType;

  const UserGrid({
    super.key,
    this.header,
    this.sectionTitleBuilder,
    this.callType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.errorMessage != current.errorMessage ||
          previous.hosts != current.hosts ||
          previous.selectedTab != current.selectedTab ||
          previous.searchQuery != current.searchQuery ||
          previous.layout != current.layout,
      builder: (context, state) {
        return RefreshIndicator(
          color: AppColors.primaryColor,
          // Also re-fetch the wallet balance so the header's points reflect
          // any change made outside a call/recharge on this device, and the
          // system config so the video/audio call cards pick up admin rate
          // changes.
          onRefresh: () => Future.wait([
            context.read<HomeCubit>().refresh(),
            context.read<WalletCubit>().fetchBalance(),
            context.read<SystemConfigCubit>().fetchConfig(),
          ]),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (header != null) ...[
                SliverToBoxAdapter(child: header),
                SliverToBoxAdapter(
                  child:
                      sectionTitleBuilder?.call(state.selectedTab) ??
                      _SectionTitle(tab: state.selectedTab),
                ),
              ],
              _buildBody(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    // Show skeleton while waiting for the initial socket snapshot
    if (state.isLoading) {
      return SliverToBoxAdapter(child: HomeSkeleton(layout: state.layout));
    }

    // Socket connection error
    if (state.errorMessage != null && state.hosts.isEmpty) {
      return _message(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 40.csp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 12.cw),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.cw),
              child: Text(
                'Unable to connect. Please check your internet and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.csp, color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      );
    }

    if (state.hosts.isEmpty) {
      return _message(
        child: Text(
          state.searchQuery.isNotEmpty
              ? AppTexts.noHostsMatch
              : 'No hosts found',
          style: TextStyle(fontSize: 14.csp, color: Colors.grey.shade500),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(
        left: 14.cw,
        right: 14.cw,
        top: 4.cw,
        bottom: 95.cw,
      ),
      sliver: _buildHosts(state),
    );
  }

  /// Grid and list share one sliver that morphs between them on a layout
  /// change. Home never toggles, so it always renders the grid.
  Widget _buildHosts(HomeState state) {
    return HostLayoutMorphSliver(
      hosts: state.hosts,
      callType: callType,
      layout: state.layout,
    );
  }

  /// Fills the rest of the viewport with a centered message; the scroll
  /// view stays pullable so [RefreshIndicator] still works.
  Widget _message({required Widget child}) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.only(top: 24.cw, bottom: 110.cw),
        child: Center(child: child),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final HomeTab tab;

  const _SectionTitle({required this.tab});

  @override
  Widget build(BuildContext context) {
    final title = switch (tab) {
      HomeTab.active => AppTexts.onlineNow,
      HomeTab.favorites => AppTexts.favorites,
      HomeTab.offline => AppTexts.offline,
      HomeTab.all => AppTexts.allHosts,
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(14.cw, 6.cw, 14.cw, 6.cw),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.csp,
          fontWeight: FontWeight.w800,
          color: AppColors.plumDeep,
        ),
      ),
    );
  }
}
