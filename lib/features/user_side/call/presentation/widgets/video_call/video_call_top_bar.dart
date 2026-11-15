import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_status_text.dart';

/// Active-call header: a minimise button (back to the floating bubble) and a
/// glass pill with a live dot, the other participant's name and the timer.
class VideoCallTopBar extends StatelessWidget {
  final String name;

  const VideoCallTopBar({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final buttonSize = 44.cw;

    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Minimise call',
          excludeSemantics: true,
          child: GestureDetector(
            // Popping the call screen minimises the call — see CallScreen's
            // PopScope.
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: _glass(BoxShape.circle),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.white,
                size: 26.csp,
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Container(
              padding: EdgeInsets.fromLTRB(12.cw, 9.cw, 16.cw, 9.cw),
              decoration: _glass(BoxShape.rectangle),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9.cw,
                    height: 9.cw,
                    decoration: const BoxDecoration(
                      color: AppColors.onlineIndicator,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.cw),
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.csp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 14.cw,
                    margin: EdgeInsets.symmetric(horizontal: 10.cw),
                    color: AppColors.white.withValues(alpha: 0.35),
                  ),
                  const _Timer(),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: buttonSize),
      ],
    );
  }

  BoxDecoration _glass(BoxShape shape) => BoxDecoration(
    shape: shape,
    borderRadius: shape == BoxShape.rectangle
        ? BorderRadius.circular(999)
        : null,
    color: AppColors.callGlassDark.withValues(alpha: 0.45),
    border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
  );
}

/// The parent builder skips duration-only ticks during a healthy active
/// call, so the timer listens to those ticks on its own.
class _Timer extends StatelessWidget {
  const _Timer();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallScreenCubit, CallScreenState>(
      buildWhen: (previous, current) =>
          previous.durationSeconds != current.durationSeconds,
      builder: (context, state) => Text(
        formatCallDuration(state.durationSeconds),
        style: TextStyle(
          fontSize: 15.csp,
          fontWeight: FontWeight.w600,
          color: AppColors.white.withValues(alpha: 0.9),
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
