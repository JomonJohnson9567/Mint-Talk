import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
import 'package:mint_talk/features/user_side/home/presentation/bloc/home_state.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/host_card_actions.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/user_grid.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/user_grid_item.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/user_list_tile.dart';

// ── Grid ↔ list morph ──────────────────────────────────────────────────────
//
// Both host layouts are fixed-extent grids, so every item's rect is a pure
// function of its index. [HostMorphGridDelegate] lerps each item between its
// grid rect and its list rect inside one lazy [SliverGrid]. Each cell keeps
// a single photo that flies from the grid photo slot into the list avatar,
// lifts while moving, and hands its text/buttons over with a cross-fade.
//
// Smoothness rules: cells are built once (the child delegate is cached), so
// an animation frame is only a relayout plus a few light wrapper rebuilds;
// the photo and both content layers are never remounted mid-morph.

const Duration kHostLayoutMorphDuration = Duration(milliseconds: 600);

/// Per-item delay step and the cap on how many items get a distinct delay,
/// so the ripple is visible near the top without making far items lag.
const double _kStaggerStep = 0.025;
const int _kStaggerMaxIndex = 10;
const double _kMaxStagger = _kStaggerStep * _kStaggerMaxIndex;

/// Eased progress of item [index] for the overall morph progress [t]
/// (0 = grid, 1 = list). Earlier items lead going to the list; the same curve
/// played backwards means later items lead going back, which keeps it
/// continuous when the toggle is tapped mid-animation.
double hostItemProgress(double t, int index) {
  final delay = math.min(index, _kStaggerMaxIndex) * _kStaggerStep;
  final local = ((t - delay) / (1 - _kMaxStagger)).clamp(0.0, 1.0);
  return Curves.easeInOutCubicEmphasized.transform(local);
}

SliverGridDelegateWithFixedCrossAxisCount hostGridDelegate(double width) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: hostGridCrossAxisCount(width),
    crossAxisSpacing: 8.cw,
    mainAxisSpacing: 10.cw,
    mainAxisExtent: hostCardExtent(
      hostCardWidth(width, hostGridCrossAxisCount(width), 8.cw),
    ),
  );
}

SliverGridDelegateWithFixedCrossAxisCount hostListDelegate(double width) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: hostListCrossAxisCount(width),
    crossAxisSpacing: 8.cw,
    mainAxisSpacing: 8.cw,
    mainAxisExtent: hostTileExtent(),
  );
}

/// Host grid/list sliver that morphs between layouts when [layout] changes.
class HostLayoutMorphSliver extends StatefulWidget {
  final List<HostEntity> hosts;
  final CallType? callType;
  final HostLayout layout;

  const HostLayoutMorphSliver({
    super.key,
    required this.hosts,
    required this.callType,
    required this.layout,
  });

  @override
  State<HostLayoutMorphSliver> createState() => _HostLayoutMorphSliverState();
}

class _HostLayoutMorphSliverState extends State<HostLayoutMorphSliver>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: _targetFor(widget.layout),
  );

  SliverConstraints? _lastConstraints;
  SliverChildDelegate? _childDelegate;
  double? _childDelegateWidth;
  _ScrollAnchor? _anchor;

  static double _targetFor(HostLayout layout) =>
      layout == HostLayout.list ? 1 : 0;

  @override
  void initState() {
    super.initState();
    // Registered before any AnimatedBuilder, so the scroll correction lands
    // in the same tick as the relayout it compensates for.
    _controller.addListener(_holdAnchor);
  }

  @override
  void didUpdateWidget(HostLayoutMorphSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.hosts, widget.hosts) ||
        oldWidget.callType != widget.callType) {
      _childDelegate = null;
    }
    if (oldWidget.layout != widget.layout) {
      _startMorph(_targetFor(widget.layout));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startMorph(double target) {
    if (MediaQuery.disableAnimationsOf(context)) {
      // Jumping synchronously here would scroll during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _anchor = _captureAnchor();
        _controller.value = target;
        _anchor = null;
      });
      return;
    }
    _anchor = _captureAnchor();
    _controller
        .animateTo(
          target,
          duration: kHostLayoutMorphDuration,
          curve: Curves.linear,
        )
        .whenComplete(() => _anchor = null);
  }

  /// When the user has scrolled into the hosts, remembers the host at the
  /// top of the viewport so [_holdAnchor] can keep it in place.
  _ScrollAnchor? _captureAnchor() {
    final constraints = _lastConstraints;
    final position = Scrollable.maybeOf(context)?.position;
    if (constraints == null ||
        position == null ||
        !position.hasPixels ||
        constraints.scrollOffset <= 0 ||
        widget.hosts.isEmpty) {
      return null;
    }
    final t = _controller.value;
    final index = HostMorphGridDelegate(t: t)
        .getLayout(constraints)
        .getMinChildIndexForScrollOffset(constraints.scrollOffset)
        .clamp(0, widget.hosts.length - 1);
    return _ScrollAnchor(
      index: index,
      constraints: constraints,
      position: position,
      startPixels: position.pixels,
      startOffset: _offsetOf(index, t, constraints),
    );
  }

  void _holdAnchor() {
    final anchor = _anchor;
    if (anchor == null || !anchor.position.hasPixels) return;
    final pixels =
        anchor.startPixels +
        _offsetOf(anchor.index, _controller.value, anchor.constraints) -
        anchor.startOffset;
    anchor.position.jumpTo(
      pixels.clamp(
        anchor.position.minScrollExtent,
        anchor.position.maxScrollExtent,
      ),
    );
  }

  static double _offsetOf(int index, double t, SliverConstraints c) =>
      HostMorphGridDelegate(
        t: t,
      ).getLayout(c).getGeometryForChildIndex(index).scrollOffset;

  SliverChildDelegate _buildChildDelegate(double width) {
    final gridCount = hostGridCrossAxisCount(width);
    final gridWidth = hostCardWidth(width, gridCount, 8.cw);
    final gridSize = Size(gridWidth, hostCardExtent(gridWidth));
    final tileSize = Size(
      hostCardWidth(width, hostListCrossAxisCount(width), 8.cw),
      hostTileExtent(),
    );
    final hosts = widget.hosts;
    final callType = widget.callType;

    return SliverChildBuilderDelegate(
      (context, index) => _HostMorphCell(
        host: hosts[index],
        callType: callType,
        index: index,
        morph: _controller,
        gridSize: gridSize,
        tileSize: tileSize,
      ),
      childCount: hosts.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        _lastConstraints = constraints;
        // This builder re-runs on every scroll frame; reusing the identical
        // delegate stops the cells from rebuilding with it.
        final width = constraints.crossAxisExtent;
        if (_childDelegate == null || _childDelegateWidth != width) {
          _childDelegateWidth = width;
          _childDelegate = _buildChildDelegate(width);
        }
        final childDelegate = _childDelegate!;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => SliverGrid(
            gridDelegate: HostMorphGridDelegate(t: _controller.value),
            delegate: childDelegate,
          ),
        );
      },
    );
  }
}

class _ScrollAnchor {
  final int index;
  final SliverConstraints constraints;
  final ScrollPosition position;
  final double startPixels;
  final double startOffset;

  const _ScrollAnchor({
    required this.index,
    required this.constraints,
    required this.position,
    required this.startPixels,
    required this.startOffset,
  });
}

/// Lays hosts out [t] of the way from the grid to the list layout.
class HostMorphGridDelegate extends SliverGridDelegate {
  final double t;

  const HostMorphGridDelegate({required this.t});

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final width = constraints.crossAxisExtent;
    return _HostMorphGridLayout(
      from: hostGridDelegate(width).getLayout(constraints),
      to: hostListDelegate(width).getLayout(constraints),
      t: t,
    );
  }

  @override
  bool shouldRelayout(HostMorphGridDelegate oldDelegate) => oldDelegate.t != t;
}

class _HostMorphGridLayout extends SliverGridLayout {
  final SliverGridLayout from;
  final SliverGridLayout to;
  final double t;

  const _HostMorphGridLayout({
    required this.from,
    required this.to,
    required this.t,
  });

  bool get _atGrid => t <= 0;
  bool get _atList => t >= 1;

  // An item outside the viewport on the same side in both layouts stays
  // outside under the lerp, so the union of both index ranges is enough.
  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    if (_atGrid) return from.getMinChildIndexForScrollOffset(scrollOffset);
    if (_atList) return to.getMinChildIndexForScrollOffset(scrollOffset);
    return math.min(
      from.getMinChildIndexForScrollOffset(scrollOffset),
      to.getMinChildIndexForScrollOffset(scrollOffset),
    );
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    if (_atGrid) return from.getMaxChildIndexForScrollOffset(scrollOffset);
    if (_atList) return to.getMaxChildIndexForScrollOffset(scrollOffset);
    return math.max(
      from.getMaxChildIndexForScrollOffset(scrollOffset),
      to.getMaxChildIndexForScrollOffset(scrollOffset),
    );
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final progress = hostItemProgress(t, index);
    if (progress <= 0) return from.getGeometryForChildIndex(index);
    if (progress >= 1) return to.getGeometryForChildIndex(index);

    final a = from.getGeometryForChildIndex(index);
    final b = to.getGeometryForChildIndex(index);
    return SliverGridGeometry(
      scrollOffset: lerpDouble(a.scrollOffset, b.scrollOffset, progress)!,
      crossAxisOffset: lerpDouble(
        a.crossAxisOffset,
        b.crossAxisOffset,
        progress,
      )!,
      mainAxisExtent: lerpDouble(a.mainAxisExtent, b.mainAxisExtent, progress)!,
      crossAxisExtent: lerpDouble(
        a.crossAxisExtent,
        b.crossAxisExtent,
        progress,
      )!,
    );
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    if (_atGrid) return from.computeMaxScrollOffset(childCount);
    if (_atList) return to.computeMaxScrollOffset(childCount);
    // Staggered items aren't ordered by offset mid-morph; only runs for the
    // few hundred milliseconds of the animation.
    var maxOffset = 0.0;
    for (var i = 0; i < childCount; i++) {
      maxOffset = math.max(
        maxOffset,
        getGeometryForChildIndex(i).trailingScrollOffset,
      );
    }
    return maxOffset;
  }
}

/// [hostItemProgress] of one cell, derived from the shared morph controller.
class _ItemProgress extends Animation<double>
    with AnimationWithParentMixin<double> {
  @override
  final Animation<double> parent;
  final int index;

  _ItemProgress(this.parent, this.index);

  @override
  double get value => hostItemProgress(parent.value, index);
}

/// One host in the morphing sliver. The card shell, the flying photo and the
/// two content layers are built once; per frame only the light wrappers
/// around them (scale, shadow, photo rect, fades) are rebuilt.
class _HostMorphCell extends StatelessWidget with HostCardActions {
  @override
  final HostEntity host;
  @override
  final CallType? callType;
  final int index;
  final Animation<double> morph;
  final Size gridSize;
  final Size tileSize;

  const _HostMorphCell({
    required this.host,
    required this.callType,
    required this.index,
    required this.morph,
    required this.gridSize,
    required this.tileSize,
  });

  static const _gridFadeOut = Interval(0, 0.45, curve: Curves.easeOut);
  static const _tileFadeIn = Interval(0.55, 1, curve: Curves.easeOut);

  /// How much a card swells while in flight, at the midpoint.
  static const double _liftScale = 0.035;

  @override
  Widget build(BuildContext context) {
    final progress = _ItemProgress(morph, index);

    final photo = IgnorePointer(child: buildPhoto());
    final gridLayer = _fixedSize(
      gridSize,
      UserGridItem(host: host, callType: callType, bare: true),
    );
    final tileLayer = _fixedSize(
      tileSize,
      UserListTile(host: host, callType: callType, bare: true),
    );

    final gridPhotoRect = Rect.fromLTWH(
      0,
      0,
      gridSize.width,
      gridSize.width / kHostPhotoAspectRatio,
    );
    final tilePhotoRect = Rect.fromLTWH(
      kHostTilePadding.cw,
      kHostTilePadding.cw,
      kHostTileAvatar.cw,
      kHostTileAvatar.cw,
    );
    final cardRadius = BorderRadius.circular(16.r);
    final avatarRadius = 12.r;
    final tileSlide = 12.cw;

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final v = progress.value;
        final lift = math.sin(math.pi * v);
        final gridOpacity = 1 - _gridFadeOut.transform(v);
        final tileOpacity = _tileFadeIn.transform(v);

        // Structure stays identical at every progress value so nothing is
        // remounted; only the inactive content layer drops out at rest.
        return Transform.scale(
          scale: 1 + _liftScale * lift,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: cardRadius,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(
                    alpha: 0.08 + 0.10 * lift,
                  ),
                  blurRadius: 14 + 14 * lift,
                  offset: Offset(0, 4 + 8 * lift),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: cardRadius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fromRect(
                    rect: Rect.lerp(gridPhotoRect, tilePhotoRect, v)!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(avatarRadius * v),
                      child: photo,
                    ),
                  ),
                  if (v < 1)
                    IgnorePointer(
                      key: const ValueKey('grid'),
                      ignoring: v > 0,
                      child: Opacity(opacity: gridOpacity, child: gridLayer),
                    ),
                  if (v > 0)
                    IgnorePointer(
                      key: const ValueKey('tile'),
                      ignoring: v < 1,
                      child: Transform.translate(
                        offset: Offset(tileSlide * (1 - tileOpacity), 0),
                        child: Opacity(opacity: tileOpacity, child: tileLayer),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Lays [child] out at its final layout size regardless of the morphing
  /// cell size. The repaint boundary sits inside the fixed constraints so
  /// its layout — and recorded picture — survive every frame of the morph.
  static Widget _fixedSize(Size size, Widget child) {
    return OverflowBox(
      alignment: Alignment.topLeft,
      minWidth: size.width,
      maxWidth: size.width,
      minHeight: size.height,
      maxHeight: size.height,
      child: RepaintBoundary(child: child),
    );
  }
}
