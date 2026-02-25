import 'package:equatable/equatable.dart';

enum SnackBarType { info, success, error, warning }

class SnackBarState extends Equatable {
  final bool isVisible;
  final String message;
  final SnackBarType? type;

  const SnackBarState({this.isVisible = false, this.message = '', this.type});

  SnackBarState copyWith({
    bool? isVisible,
    String? message,
    SnackBarType? type,
  }) {
    return SnackBarState(
      isVisible: isVisible ?? this.isVisible,
      message: message ?? this.message,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [isVisible, message, type];
}
