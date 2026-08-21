import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/user_side/call/presentation/cubit/draggable_video_preview_cubit.dart';

/// A WhatsApp/Instagram-style draggable picture-in-picture container.
///
/// Free-drags anywhere within [boundaryWidth]/[boundaryHeight] while the
/// user's finger is down, then snaps to whichever horizontal edge it's
/// closer to on release. Purely ephemeral UI position state — not part of
/// call business state — held in a local [DraggableVideoPreviewCubit].
class DraggableVideoPreview extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double boundaryWidth;
  final double boundaryHeight;
  final double margin;
  final BorderRadius borderRadius;

  const DraggableVideoPreview({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    required this.boundaryWidth,
    required this.boundaryHeight,
    this.margin = 20,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DraggableVideoPreviewCubit(
        width: width,
        height: height,
        boundaryWidth: boundaryWidth,
        boundaryHeight: boundaryHeight,
        margin: margin,
      ),
      child: Builder(
        builder: (context) {
          // Runs on every rebuild of this ancestor Builder (before the
          // BlocBuilder below is (re)built), safely re-syncing geometry
          // into the cubit — the Cubit/BlocBuilder equivalent of
          // `didUpdateWidget`.
          context.read<DraggableVideoPreviewCubit>().syncBoundary(
            width: width,
            height: height,
            boundaryWidth: boundaryWidth,
            boundaryHeight: boundaryHeight,
            margin: margin,
          );

          return BlocBuilder<
            DraggableVideoPreviewCubit,
            DraggableVideoPreviewState
          >(
            builder: (context, state) {
              final cubit = context.read<DraggableVideoPreviewCubit>();
              return AnimatedPositioned(
                duration: state.isDragging
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                left: state.offset.dx,
                top: state.offset.dy,
                width: width,
                height: height,
                child: GestureDetector(
                  onPanStart: (_) => cubit.dragStart(),
                  onPanUpdate: (details) => cubit.dragUpdate(details.delta),
                  onPanEnd: (_) => cubit.dragEnd(),
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
