import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../transitions/cubit/snack_bar_cubit.dart';
import '../transitions/cubit/snack_bar_state.dart';
import '../transitions/widgets/sliding_snackbar_wrapper.dart';
import '../theme/color.dart';

class TopSnackbar extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final Color? backgroundColor;

  const TopSnackbar({
    super.key,
    required this.message,
    this.onDismiss,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        margin: EdgeInsets.only(top: 50.h, left: 20.w, right: 20.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primaryColor,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Message Text
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            /// Close Button
            if (onDismiss != null)
              GestureDetector(
                onTap: onDismiss,
                child: Icon(Icons.close, color: AppColors.white, size: 20.sp),
              ),
          ],
        ),
      ),
    );
  }
}

OverlayEntry? _currentOverlayEntry;
SnackBarCubit? _currentSnackBarCubit;
Timer? _hideTimer;
Timer? _removeTimer;

void showTopSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  SnackBarType? type,
}) {
  final overlay = Overlay.of(context);

  /// Cancel existing timers to prevent premature dismissal
  _hideTimer?.cancel();
  _removeTimer?.cancel();

  /// Create new overlay if none exists or previous one is unmounted
  if (_currentOverlayEntry == null || _currentOverlayEntry?.mounted == false) {
    _currentSnackBarCubit = SnackBarCubit();
    _currentOverlayEntry = OverlayEntry(
      builder: (_) => BlocProvider.value(
        value: _currentSnackBarCubit!,
        child: const SlidingSnackbarWrapper(),
      ),
    );

    overlay.insert(_currentOverlayEntry!);
  }

  /// Trigger animation and update message
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _currentSnackBarCubit?.show(message, type: type);
  });

  /// Schedule auto-dismiss
  _hideTimer = Timer(const Duration(seconds: 3), () {
    _currentSnackBarCubit?.hide();

    /// Create new timer for removal after animation
    _removeTimer = Timer(const Duration(milliseconds: 500), () {
      if (_currentOverlayEntry != null && _currentOverlayEntry!.mounted) {
        _currentOverlayEntry?.remove();
      }
      _currentSnackBarCubit?.close();
      _currentOverlayEntry = null;
      _currentSnackBarCubit = null;
    });
  });
}
