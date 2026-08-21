import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DraggableVideoPreviewState extends Equatable {
  final Offset offset;
  final bool isDragging;

  const DraggableVideoPreviewState({
    required this.offset,
    this.isDragging = false,
  });

  DraggableVideoPreviewState copyWith({Offset? offset, bool? isDragging}) {
    return DraggableVideoPreviewState(
      offset: offset ?? this.offset,
      isDragging: isDragging ?? this.isDragging,
    );
  }

  @override
  List<Object?> get props => [offset, isDragging];
}

/// Free-drags the picture-in-picture video tile anywhere within the
/// boundary while the user's finger is down, then snaps to whichever
/// horizontal edge it's closer to on release. Purely ephemeral UI position
/// state — not part of call business state — but modeled as a Cubit rather
/// than widget State per the app's stateless-only convention.
class DraggableVideoPreviewCubit extends Cubit<DraggableVideoPreviewState> {
  double _width;
  double _height;
  double _boundaryWidth;
  double _boundaryHeight;
  double _margin;

  DraggableVideoPreviewCubit({
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
         DraggableVideoPreviewState(
           offset: Offset(boundaryWidth - width - margin, margin),
         ),
       );

  Offset _clamp(Offset offset) {
    final maxX = (_boundaryWidth - _width).clamp(0.0, double.infinity);
    final maxY = (_boundaryHeight - _height).clamp(0.0, double.infinity);
    return Offset(offset.dx.clamp(0.0, maxX), offset.dy.clamp(0.0, maxY));
  }

  /// Re-syncs the geometry the widget was built with (called on every
  /// build) and re-clamps the offset if the boundary actually changed
  /// (e.g. rotation) — replicates the old `didUpdateWidget` behavior so
  /// the preview never ends up stranded off-screen.
  void syncBoundary({
    required double width,
    required double height,
    required double boundaryWidth,
    required double boundaryHeight,
    required double margin,
  }) {
    final boundaryChanged =
        _boundaryWidth != boundaryWidth || _boundaryHeight != boundaryHeight;
    _width = width;
    _height = height;
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
    final targetX = (current.dx + _width / 2) < midX
        ? _margin
        : _boundaryWidth - _width - _margin;
    emit(
      state.copyWith(
        offset: Offset(targetX, current.dy),
        isDragging: false,
      ),
    );
  }
}
