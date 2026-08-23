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
class FloatingCallBubbleCubit extends Cubit<FloatingCallBubbleState> {
  double _size;
  double _boundaryWidth;
  double _boundaryHeight;
  double _margin;

  FloatingCallBubbleCubit({
    required double size,
    required double boundaryWidth,
    required double boundaryHeight,
    required double margin,
  }) : _size = size,
       _boundaryWidth = boundaryWidth,
       _boundaryHeight = boundaryHeight,
       _margin = margin,
       super(
         FloatingCallBubbleState(
           offset: Offset(
             boundaryWidth - size - margin,
             boundaryHeight - size - margin * 4,
           ),
         ),
       );

  Offset _clamp(Offset offset) {
    final maxX = (_boundaryWidth - _size).clamp(0.0, double.infinity);
    final maxY = (_boundaryHeight - _size).clamp(0.0, double.infinity);
    return Offset(offset.dx.clamp(0.0, maxX), offset.dy.clamp(0.0, maxY));
  }

  void syncBoundary({
    required double size,
    required double boundaryWidth,
    required double boundaryHeight,
    required double margin,
  }) {
    final boundaryChanged =
        _boundaryWidth != boundaryWidth || _boundaryHeight != boundaryHeight;
    _size = size;
    _boundaryWidth = boundaryWidth;
    _boundaryHeight = boundaryHeight;
    _margin = margin;
    if (boundaryChanged) {
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
    final targetX = (current.dx + _size / 2) < midX
        ? _margin
        : _boundaryWidth - _size - _margin;
    emit(
      state.copyWith(offset: Offset(targetX, current.dy), isDragging: false),
    );
  }
}
