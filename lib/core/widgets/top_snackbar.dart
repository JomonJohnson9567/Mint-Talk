import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_icons.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
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
                child: Icon(
                  AppIcons.close,
                  color: AppColors.white,
                  size: 20.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The one snackbar overlay currently in use. Each handle owns its own entry,
/// cubit and timers — nothing is read back through a nullable global at
/// build time.
_TopSnackBarHandle? _active;

class _TopSnackBarHandle {
  _TopSnackBarHandle(this.overlay) : cubit = SnackBarCubit() {
    entry = OverlayEntry(
      // Captures [cubit] directly. The entry is built on the next *rendered*
      // frame, which while the app is backgrounded can be long after this
      // runs — it must not depend on state that may be cleared meanwhile.
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const SlidingSnackbarWrapper(),
      ),
    );
    overlay.insert(entry);
  }

  final OverlayState overlay;
  final SnackBarCubit cubit;
  late final OverlayEntry entry;
  Timer? _hideTimer;
  Timer? _removeTimer;
  bool isDisposed = false;

  void cancelTimers() {
    _hideTimer?.cancel();
    _removeTimer?.cancel();
  }

  /// Shows [message] and only then starts the auto-dismiss countdown, so
  /// time spent backgrounded (no frames) never counts against it.
  void show(String message, SnackBarType? type) {
    if (isDisposed) return;
    cancelTimers();
    cubit.show(message, type: type);
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (isDisposed) return;
      cubit.hide();
      // Removal after the slide-out animation.
      _removeTimer = Timer(const Duration(milliseconds: 500), () {
        dispose();
        if (identical(_active, this)) _active = null;
      });
    });
  }

  void dispose() {
    if (isDisposed) return;
    isDisposed = true;
    cancelTimers();
    // Unconditional — not gated on `entry.mounted`, which stays false until
    // a frame builds the entry. Gating on it is what used to orphan entries
    // inserted while the app was backgrounded.
    entry.remove();
    entry.dispose();
    cubit.close();
  }
}

void showTopSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  SnackBarType? type,
}) {
  // A caller's context may already be gone (e.g. a call screen popped
  // between the event and this call) — fall back to the root Navigator's
  // overlay, which is the one a mounted context resolves to anyway.
  final overlay = context.mounted
      ? Overlay.maybeOf(context)
      : getIt<NavigationService>().navigatorKey.currentState?.overlay;
  if (overlay == null || !overlay.mounted) return;

  var handle = _active;
  if (handle == null ||
      handle.isDisposed ||
      !identical(handle.overlay, overlay)) {
    handle?.dispose();
    handle = _TopSnackBarHandle(overlay);
    _active = handle;
  }

  /// Cancel existing timers to prevent premature dismissal
  handle.cancelTimers();

  // Reusing an existing entry schedules no frame by itself. No-op while the
  // app is backgrounded (frames disabled) — the callback below then simply
  // runs on the first frame after resume.
  WidgetsBinding.instance.ensureVisualUpdate();

  /// Trigger animation, update message and start the auto-dismiss countdown
  /// once a frame has actually rendered the entry.
  final shown = handle;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    shown.show(message, type);
  });
}
