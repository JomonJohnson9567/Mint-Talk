import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FloatingCallBubbleState extends Equatable {
  final Offset offset;
  final bool isDragging;

  const FloatingCallBubbleState({
    required this.offset,
    this.isDragging = false,
  });

  FloatingCallBubbleState copyWith({Offset? offset, bool? isDragging}) {
    return FloatingCallBubbleState(
      offset: offset ?? this.offset,
      isDragging: isDragging ?? this.isDragging,
    );
  }

  @override
  List<Object?> get props => [offset, isDragging];
}

/// Free-drags the floating call bubble anywhere within the screen while the
/// user's finger is down, then snaps to whichever horizontal edge it's
/// closer to on release — same mechanics as [DraggableVideoPreviewCubit],
/// but sized against the whole screen (via [syncBoundary]) rather than one
/// screen's local layout, since this bubble floats above the entire app.
///
/// The bubble is not necessarily square (portrait video card, horizontal
/// audio pill), so width and height are tracked separately.
class FloatingCallBubbleCubit extends Cubit<FloatingCallBubbleState> {
  double _width;
  double _height;
  double _boundaryWidth;
  double _boundaryHeight;
  double _margin;

  FloatingCallBubbleCubit({
    required double width,
    required double height,
    required double boundaryWidth,
    required double boundaryHeight,
    required double margin,
  }) : _width = width,
       _height = height,
       _boundaryWidth = boundaryWidth,
       _boundaryHeight = boundaryHeight,
       _margin = margin,
       super(
         FloatingCallBubbleState(
           offset: Offset(
             boundaryWidth - width - margin,
             boundaryHeight - height - margin * 4,
           ),
         ),
       );

  Offset _clamp(Offset offset) {
    final maxX = (_boundaryWidth - _width).clamp(0.0, double.infinity);
    final maxY = (_boundaryHeight - _height).clamp(0.0, double.infinity);
    return Offset(offset.dx.clamp(0.0, maxX), offset.dy.clamp(0.0, maxY));
  }

  void syncBoundary({
    required double width,
    required double height,
    required double boundaryWidth,
    required double boundaryHeight,
    required double margin,
  }) {
    final changed =
        _width != width ||
        _height != height ||
        _boundaryWidth != boundaryWidth ||
        _boundaryHeight != boundaryHeight;
    _width = width;
    _height = height;
    _boundaryWidth = boundaryWidth;
    _boundaryHeight = boundaryHeight;
    _margin = margin;
    if (changed) {
      emit(state.copyWith(offset: _clamp(state.offset)));
    }
  }

  void dragStart() => emit(state.copyWith(isDragging: true));

  void dragUpdate(Offset delta) {
    emit(state.copyWith(offset: _clamp(state.offset + delta)));
  }

  void dragEnd() {
    final current = _clamp(state.offset);
    final midX = _boundaryWidth / 2;
    final targetX = (current.dx + _width / 2) < midX
        ? _margin
        : _boundaryWidth - _width - _margin;
    emit(
      state.copyWith(offset: Offset(targetX, current.dy), isDragging: false),
    );
  }
}
