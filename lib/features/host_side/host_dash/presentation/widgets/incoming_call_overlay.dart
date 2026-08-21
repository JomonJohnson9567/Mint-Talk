import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/cubit/pressed_state_cubit.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/transitions/widgets/animated_breathing_glow.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/incoming_call_overlay_cubit.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/incoming_call_session_cubit.dart';
import 'package:mint_talk/features/user_side/call/data/models/incoming_call_payload_dto.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/reject_call_usecase.dart';
import 'package:mint_talk/features/user_side/call/presentation/screen/call_screen.dart';

class IncomingCallOverlayListener extends StatelessWidget {
  final Widget child;

  const IncomingCallOverlayListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IncomingCallOverlayCubit(
        presenceSocketService: getIt<IPresenceSocketService>(),
      ),
      child: Builder(
        builder: (context) {
          return BlocListener<IncomingCallOverlayCubit, IncomingCallPayloadDto?>(
            listenWhen: (previous, current) => current != null,
            listener: (context, payload) {
              final cubit = context.read<IncomingCallOverlayCubit>();
              showGeneralDialog(
                context: context,
                barrierDismissible: false,
                barrierColor: Colors.black.withValues(alpha: 0.6),
                useRootNavigator: true,
                transitionDuration: const Duration(milliseconds: 420),
                pageBuilder: (dialogContext, animation, secondaryAnimation) {
                  return _IncomingCallFullScreenModal(payload: payload!);
                },
                transitionBuilder:
                    (dialogContext, animation, secondaryAnimation, child) {
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      );
                      return FadeTransition(
                        opacity: curved,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.94,
                            end: 1.0,
                          ).animate(curved),
                          child: child,
                        ),
                      );
                    },
              ).then((_) {
                cubit.dialogDismissed();
              });
            },
            child: child,
          );
        },
      ),
    );
  }
}

class _IncomingCallFullScreenModal extends StatelessWidget {
  final IncomingCallPayloadDto payload;

  const _IncomingCallFullScreenModal({required this.payload});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IncomingCallSessionCubit(
        payload: payload,
        onDismiss: () {
          final navigator = Navigator.of(context, rootNavigator: true);
          if (navigator.canPop()) {
            navigator.pop();
          }
        },
        presenceSocketService: getIt<IPresenceSocketService>(),
        rejectCallUseCase: getIt<RejectCallUseCase>(),
      ),
      child: _IncomingCallFullScreenModalContent(payload: payload),
    );
  }
}

class _IncomingCallFullScreenModalContent extends StatelessWidget {
  final IncomingCallPayloadDto payload;

  const _IncomingCallFullScreenModalContent({required this.payload});

  void _handleAccept(BuildContext context) {
    final cubit = context.read<IncomingCallSessionCubit>();
    if (cubit.state.isProcessing) return;
    HapticFeedback.mediumImpact();

    // Navigate immediately — CallScreen performs the HTTP accept call
    // itself (CallScreenCubit.acceptIncomingCall) once it's already on
    // screen, showing its own "connecting" UI, instead of this overlay
    // blocking on the network round trip before ever leaving the ringing
    // screen.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CallScreen(
          incomingPayload: payload,
          callType: payload.callType,
          hostName: payload.callerName,
          hostAvatar: payload.callerAvatar,
          isHost: true,
        ),
      ),
    );
    cubit.handOffToCallScreen();
  }

  Future<void> _handleReject(BuildContext context) async {
    final cubit = context.read<IncomingCallSessionCubit>();
    if (cubit.state.isProcessing) return;
    HapticFeedback.lightImpact();
    await cubit.reject();
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = payload.callType.isVideo;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(AppColors.primaryColor, AppColors.black, 0.55)!,
              Color.lerp(AppColors.primaryColor, AppColors.black, 0.82)!,
              AppColors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80.r,
              right: -60.r,
              child: Container(
                width: 220.r,
                height: 220.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withValues(alpha: 0.18),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    _AnimatedFadeSlideIn(
                      delay: const Duration(milliseconds: 60),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Text(
                          'INCOMING ${isVideo ? "VIDEO" : "AUDIO"} CALL',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 44.h),
                    _AnimatedFadeSlideIn(
                      delay: const Duration(milliseconds: 140),
                      child: BlocBuilder<IncomingCallSessionCubit, IncomingCallSessionState>(
                        buildWhen: (previous, current) =>
                            previous.ringPhase != current.ringPhase ||
                            previous.isAvatarExpanded != current.isAvatarExpanded,
                        builder: (context, state) {
                          return _RingingAvatar(
                            ringPhase: state.ringPhase,
                            child: AnimatedBreathingGlow(
                              isExpanded: state.isAvatarExpanded,
                              glowColor: AppColors.primaryColor,
                              secondaryGlowColor: AppColors.callBreathingGlowSoft,
                              collapsedSize: 152.w,
                              expandedSize: 168.w,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.white.withValues(alpha: 0.5),
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 60.r,
                                  backgroundColor: AppColors.primaryColor
                                      .withValues(alpha: 0.2),
                                  backgroundImage:
                                      (payload.callerAvatar?.isNotEmpty ?? false)
                                      ? NetworkImage(payload.callerAvatar!)
                                      : null,
                                  child: (payload.callerAvatar?.isNotEmpty ?? false)
                                      ? null
                                      : Icon(
                                          Icons.person,
                                          size: 56.r,
                                          color: AppColors.white,
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 28.h),
                    _AnimatedFadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        payload.callerName.isNotEmpty
                            ? payload.callerName
                            : 'Incoming Caller',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _AnimatedFadeSlideIn(
                      delay: const Duration(milliseconds: 240),
                      child: Text(
                        'Ringing...',
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.7),
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    const Spacer(),
                    BlocBuilder<IncomingCallSessionCubit, IncomingCallSessionState>(
                      buildWhen: (previous, current) =>
                          previous.isProcessing != current.isProcessing,
                      builder: (context, state) {
                        if (state.isProcessing) {
                          return CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          );
                        }
                        return _AnimatedFadeSlideIn(
                          delay: const Duration(milliseconds: 320),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _CallActionButton(
                                onTap: () => _handleReject(context),
                                backgroundColor: AppColors.red,
                                icon: Icons.call_end,
                                label: 'Decline',
                              ),
                              _CallActionButton(
                                onTap: () => _handleAccept(context),
                                backgroundColor: AppColors.green,
                                icon: isVideo ? Icons.videocam : Icons.call,
                                label: 'Accept',
                                pulse: true,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fades and slides its child up into place, staggered by [delay]. Pure UI
/// timing with no business state, so it's a lossless implicit-animation
/// swap rather than a Cubit-driven one.
class _AnimatedFadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedFadeSlideIn({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        final visible = snapshot.connectionState == ConnectionState.done;
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          opacity: visible ? 1 : 0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            offset: visible ? Offset.zero : const Offset(0, 0.12),
            child: child,
          ),
        );
      },
    );
  }
}

/// Expanding, fading rings behind the caller avatar, like a radar ping.
class _RingingAvatar extends StatelessWidget {
  final double ringPhase;
  final Widget child;

  const _RingingAvatar({required this.ringPhase, required this.child});

  @override
  Widget build(BuildContext context) {
    // Fixed footprint so the rings' continuous grow-and-reset cycle never
    // changes this widget's own size — otherwise every wrap-around (ring
    // shrinking back from its max size to its start size) yanks the Column
    // layout beneath it (the caller name) into a visible jump.
    return SizedBox(
      width: 260.w,
      height: 260.w,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          for (final offset in [0.0, 0.5]) _pulseRing((ringPhase + offset) % 1.0),
          child,
        ],
      ),
    );
  }

  Widget _pulseRing(double progress) {
    final size = 168.w + (progress * 80.w);
    final opacity = (1 - progress).clamp(0.0, 1.0) * 0.35;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: opacity),
          width: 2,
        ),
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final IconData icon;
  final String label;
  final bool pulse;

  const _CallActionButton({
    required this.onTap,
    required this.backgroundColor,
    required this.icon,
    required this.label,
    this.pulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PressedStateCubit(),
      child: Builder(
        builder: (context) {
          final cubit = context.read<PressedStateCubit>();
          return GestureDetector(
            onTapDown: (_) => cubit.press(),
            onTapUp: (_) => cubit.release(),
            onTapCancel: cubit.release,
            onTap: onTap,
            child: Column(
              children: [
                BlocBuilder<PressedStateCubit, bool>(
                  builder: (context, isPressed) {
                    return AnimatedScale(
                      scale: isPressed ? 0.88 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      child: Container(
                        width: 72.w,
                        height: 72.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              backgroundColor,
                              Color.lerp(
                                backgroundColor,
                                AppColors.black,
                                0.25,
                              )!,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: backgroundColor.withValues(alpha: 0.45),
                              blurRadius: 20,
                              spreadRadius: pulse ? 2 : 0,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: AppColors.white, size: 32),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8.h),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
