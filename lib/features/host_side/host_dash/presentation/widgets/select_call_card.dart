import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import '../cubit/host_dash_state.dart';
import 'host_dash_motion.dart';
import 'pulsing_online_border.dart';

/// Plum gradient shared by the waiting and incoming-call views.
const LinearGradient _plumGradient = LinearGradient(
  colors: [
    AppColors.hostGoOnlineStart,
    AppColors.primaryColor,
    AppColors.plumDeep,
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

List<BoxShadow> get _plumShadow => [
  BoxShadow(
    color: AppColors.plumDeep.withValues(alpha: 0.3),
    blurRadius: 20,
    offset: const Offset(0, 12),
  ),
];

class SelectCallCard extends StatelessWidget {
  final HostDashCallFlowMode callFlowMode;
  final bool isVideoSelected;
  final bool isAudioSelected;
  final bool isAnyCallSelected;
  final bool isStartingCall;
  final bool isSocketConnected;
  final String selectedCallLabel;
  final VoidCallback onVideoToggle;
  final VoidCallback onAudioToggle;
  final VoidCallback onReadyTapped;
  final VoidCallback onPickupTapped;
  final VoidCallback onDeclineTapped;
  final VoidCallback onStopWaitingTapped;
  final VoidCallback onReconnectTapped;

  const SelectCallCard({
    super.key,
    required this.callFlowMode,
    required this.isVideoSelected,
    required this.isAudioSelected,
    required this.isAnyCallSelected,
    required this.isStartingCall,
    required this.isSocketConnected,
    required this.selectedCallLabel,
    required this.onVideoToggle,
    required this.onAudioToggle,
    required this.onReadyTapped,
    required this.onPickupTapped,
    required this.onDeclineTapped,
    required this.onStopWaitingTapped,
    required this.onReconnectTapped,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content;

    if (callFlowMode == HostDashCallFlowMode.incomingCall) {
      content = _IncomingCallView(
        key: const ValueKey('incoming'),
        selectedCallLabel: selectedCallLabel,
        onPickupTapped: onPickupTapped,
        onDeclineTapped: onDeclineTapped,
      );
    } else if (callFlowMode == HostDashCallFlowMode.waitingForNextCall) {
      content = _WaitingCallView(
        key: const ValueKey('waiting'),
        onStopWaitingTapped: onStopWaitingTapped,
        isSocketConnected: isSocketConnected,
        onReconnectTapped: onReconnectTapped,
      );
    } else {
      content = _SelectionView(
        key: const ValueKey('selection'),
        isVideoSelected: isVideoSelected,
        isAudioSelected: isAudioSelected,
        isAnyCallSelected: isAnyCallSelected,
        isStartingCall: isStartingCall,
        onVideoToggle: onVideoToggle,
        onAudioToggle: onAudioToggle,
        onReadyTapped: onReadyTapped,
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 5.cw),
      child: HostDashSwitcher(child: content),
    );
  }
}

class _SelectionView extends StatelessWidget {
  final bool isVideoSelected;
  final bool isAudioSelected;
  final bool isAnyCallSelected;
  final bool isStartingCall;
  final VoidCallback onVideoToggle;
  final VoidCallback onAudioToggle;
  final VoidCallback onReadyTapped;

  const _SelectionView({
    super.key,
    required this.isVideoSelected,
    required this.isAudioSelected,
    required this.isAnyCallSelected,
    required this.isStartingCall,
    required this.onVideoToggle,
    required this.onAudioToggle,
    required this.onReadyTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.cw, 18.cw, 14.cw, 14.cw),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.profileDivider, width: 1.cw),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.cw),
            child: Text(
              AppTexts.hostReadyToConnect,
              style: TextStyle(
                fontSize: 20.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
          ),
          SizedBox(height: 4.cw),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.cw),
            child: Text(
              AppTexts.chooseCallTypes,
              style: TextStyle(
                fontSize: 12.5.csp,
                fontWeight: FontWeight.w500,
                color: AppColors.hostSubtitle,
              ),
            ),
          ),
          SizedBox(height: 14.cw),
          Row(
            children: [
              Expanded(
                child: _CallTypeTile(
                  selected: isAudioSelected,
                  title: AppTexts.audioCallLabel,
                  iconData: Icons.call_rounded,
                  onTap: onAudioToggle,
                  accent: AppColors.audioAccent,
                  selectedBackground: AppColors.hostAudioTileBg,
                ),
              ),
              SizedBox(width: 10.cw),
              Expanded(
                child: _CallTypeTile(
                  selected: isVideoSelected,
                  title: AppTexts.videoCallLabel,
                  iconData: Icons.videocam_rounded,
                  onTap: onVideoToggle,
                  accent: AppColors.hostVideoAccent,
                  selectedBackground: AppColors.hostVideoTileBg,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.cw),
          _GoOnlineButton(
            isEnabled: isAnyCallSelected,
            isLoading: isStartingCall,
            onTap: onReadyTapped,
          ),
        ],
      ),
    );
  }
}

class _GoOnlineButton extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _GoOnlineButton({
    required this.isEnabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = isEnabled || isLoading;
    final Color textColor = active ? AppColors.white : AppColors.plumHint;

    return GestureDetector(
      onTap: isEnabled && !isLoading ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        height: 52.cw,
        decoration: BoxDecoration(
          color: active ? null : AppColors.pillUnselected,
          gradient: active
              ? const LinearGradient(
                  colors: [
                    AppColors.hostGoOnlineStart,
                    AppColors.primaryColor,
                    AppColors.plumDeep,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 18.cw,
                height: 18.cw,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              ),
              SizedBox(width: 10.cw),
            ],
            Text(
              isLoading
                  ? AppTexts.connecting
                  : isEnabled
                  ? AppTexts.goOnline
                  : AppTexts.selectACallType,
              style: TextStyle(
                fontSize: 16.csp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (isEnabled && !isLoading) ...[
              SizedBox(width: 10.cw),
              Icon(Icons.arrow_forward_rounded, color: textColor, size: 20.csp),
            ],
          ],
        ),
      ),
    );
  }
}

class _IncomingCallView extends StatelessWidget {
  final String selectedCallLabel;
  final VoidCallback onPickupTapped;
  final VoidCallback onDeclineTapped;

  const _IncomingCallView({
    super.key,
    required this.selectedCallLabel,
    required this.onPickupTapped,
    required this.onDeclineTapped,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : 260.h;
        final double topBlockHeight = availableHeight * 0.66;
        final double avatarSize = (availableHeight * 0.30).clamp(56.0, 84.0);
        final double actionButtonSize = (availableHeight * 0.24).clamp(
          58.0,
          86.0,
        );
        final double titleFontSize = (availableHeight * 0.10).clamp(16.0, 20.0);
        final double subtitleFontSize = (availableHeight * 0.075).clamp(
          12.0,
          17.0,
        );

        return Container(
          constraints: BoxConstraints(minHeight: 220.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.r),
            gradient: _plumGradient,
            boxShadow: _plumShadow,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22.r),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -42.h,
                        right: -22.w,
                        child: Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -36.w,
                        top: 24.h,
                        child: _StreakBand(width: 160.w, angle: -0.3),
                      ),
                      Positioned(
                        right: -40.w,
                        top: 96.h,
                        child: _StreakBand(width: 170.w, angle: 0.25),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: topBlockHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            width: avatarSize,
                            height: avatarSize,
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColors.hostAvatarBg,
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18.r),
                              child: Image.asset(
                                AppAssets.femaleIcon,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.account_circle_rounded,
                                      size: avatarSize * 0.62,
                                      color: AppColors.primaryColor,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Rino george',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w900,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            selectedCallLabel,
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ActionCircleButton(
                        color: AppColors.callEndedStatus,
                        icon: Icons.call_end_rounded,
                        label: 'Not now',
                        onTap: onDeclineTapped,
                        size: actionButtonSize,
                      ),
                      _ActionCircleButton(
                        color: AppColors.callBreathingGlow,
                        icon: Icons.call_rounded,
                        label: 'Pickup',
                        onTap: onPickupTapped,
                        size: actionButtonSize,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WaitingCallView extends StatelessWidget {
  final VoidCallback onStopWaitingTapped;
  final bool isSocketConnected;
  final VoidCallback onReconnectTapped;

  const _WaitingCallView({
    super.key,
    required this.onStopWaitingTapped,
    required this.isSocketConnected,
    required this.onReconnectTapped,
  });

  @override
  Widget build(BuildContext context) {
    final double cardRadius = 22.r;

    final Widget card = Container(
      padding: EdgeInsets.fromLTRB(16.cw, 16.cw, 16.cw, 18.cw),
      decoration: BoxDecoration(
        color: AppColors.hostWaitingCard,
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Column(
        children: [
          // The mascot image is opaque — its background matches
          // AppColors.hostWaitingCard, so it reads as part of the card.
          Image.asset(
            AppAssets.hostWaitingMascot,
            height: 200.cw,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 14.cw),
          Text(
            AppTexts.waitingForNextHello,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.csp,
              fontWeight: FontWeight.w800,
              color: AppColors.plumDeep,
            ),
          ),
          SizedBox(height: 6.cw),
          Text(
            AppTexts.nextConversationAppearsHere,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.csp,
              fontWeight: FontWeight.w500,
              color: AppColors.hostSubtitle,
            ),
          ),
          SizedBox(height: 18.cw),
          SizedBox(
            width: double.infinity,
            height: 50.cw,
            child: OutlinedButton(
              onPressed: onStopWaitingTapped,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: BorderSide(color: AppColors.primaryColor, width: 1.5.cw),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Text(
                AppTexts.stopWaiting,
                style: TextStyle(fontSize: 16.csp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isSocketConnected) ...[
          _ReconnectBanner(onReconnectTapped: onReconnectTapped),
          SizedBox(height: 10.h),
        ],
        isSocketConnected
            ? PulsingOnlineBorder(
                borderRadius: cardRadius,
                color: AppColors.hostVideoAccent,
                child: card,
              )
            : card,
      ],
    );
  }
}

class _ReconnectBanner extends StatelessWidget {
  final VoidCallback onReconnectTapped;

  const _ReconnectBanner({required this.onReconnectTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.audioBtnBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.audioAccent.withValues(alpha: 0.4),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: AppColors.audioAccent,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              "Not connected — you're not receiving calls right now.",
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.plumDeep,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onReconnectTapped,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Reconnect',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CallTypeTile extends StatelessWidget {
  final bool selected;
  final String title;
  final IconData iconData;
  final VoidCallback onTap;
  final Color accent;
  final Color selectedBackground;

  const _CallTypeTile({
    required this.selected,
    required this.title,
    required this.iconData,
    required this.onTap,
    required this.accent,
    required this.selectedBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.fromLTRB(14.cw, 14.cw, 12.cw, 16.cw),
          decoration: BoxDecoration(
            color: selected ? selectedBackground : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: selected
                  ? AppColors.primaryColor
                  : AppColors.profileDivider,
              width: selected ? 1.5.cw : 1.cw,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54.cw,
                    height: 54.cw,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: AppColors.white, size: 26.csp),
                  ),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 22.cw,
                    height: 22.cw,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryColor
                          : AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryColor
                            : AppColors.plumHint,
                        width: 1.5.cw,
                      ),
                    ),
                    child: selected
                        ? Icon(
                            Icons.check_rounded,
                            color: AppColors.white,
                            size: 14.csp,
                          )
                        : null,
                  ),
                ],
              ),
              SizedBox(height: 12.cw),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.csp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.plumDeep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCircleButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double size;

  const _ActionCircleButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.white, size: size * 0.42),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBand extends StatelessWidget {
  final double width;
  final double angle;

  const _StreakBand({required this.width, required this.angle});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Column(
        children: List.generate(
          6,
          (index) => Container(
            margin: EdgeInsets.only(bottom: 10.h),
            width: width - (index * 10.w),
            height: 1.2.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08 + (index * 0.012)),
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
        ),
      ),
    );
  }
}
