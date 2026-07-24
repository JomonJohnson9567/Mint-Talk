import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';
import '../cubit/host_dash_state.dart';

class SelectCallCard extends StatelessWidget {
  final HostDashCallFlowMode callFlowMode;
  final bool isVideoSelected;
  final bool isAudioSelected;
  final bool isAnyCallSelected;
  final bool isStartingCall;
  final String selectedCallLabel;
  final VoidCallback onVideoToggle;
  final VoidCallback onAudioToggle;
  final VoidCallback onReadyTapped;
  final VoidCallback onPickupTapped;
  final VoidCallback onDeclineTapped;
  final VoidCallback onStopWaitingTapped;

  const SelectCallCard({
    super.key,
    required this.callFlowMode,
    required this.isVideoSelected,
    required this.isAudioSelected,
    required this.isAnyCallSelected,
    required this.isStartingCall,
    required this.selectedCallLabel,
    required this.onVideoToggle,
    required this.onAudioToggle,
    required this.onReadyTapped,
    required this.onPickupTapped,
    required this.onDeclineTapped,
    required this.onStopWaitingTapped,
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
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: content,
      ),
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
    final Color primaryTint = AppColors.primaryColor.withValues(alpha: 0.1);
    final Color readyColor = isAnyCallSelected
        ? AppColors.primaryColor
        : const Color(0xFFE7EBF3);
    final Color readyTextColor = isAnyCallSelected ? AppColors.white : const Color(0xFF9E9E9E);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE7EBF3), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select the call you are ready to take',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'You can enable audio, video, or both.',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.subtitleText,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _CallTypeTile(
                  selected: isAudioSelected,
                  title: 'Audio Call',
                  subtitle: 'Earn per minute',
                  iconData: Icons.phone_rounded,
                  onTap: onAudioToggle,
                  selectedTint: primaryTint,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _CallTypeTile(
                  selected: isVideoSelected,
                  title: 'Video Call',
                  subtitle: 'Earn more',
                  iconData: Icons.videocam_rounded,
                  onTap: onVideoToggle,
                  selectedTint: primaryTint,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: isAnyCallSelected && !isStartingCall ? onReadyTapped : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isStartingCall ? AppColors.primaryColor : readyColor,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: isAnyCallSelected || isStartingCall
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isStartingCall)
                    SizedBox(
                      width: 18.sp,
                      height: 18.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(readyTextColor),
                      ),
                    )
                  else
                    Icon(
                      Icons.sensors_rounded,
                      color: readyTextColor,
                      size: 18.sp,
                    ),
                  SizedBox(width: 8.w),
                  Text(
                    isStartingCall
                        ? 'Connecting...'
                        : isAnyCallSelected
                            ? 'Ready'
                            : 'Select a call type',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: readyTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        final double actionButtonSize = (availableHeight * 0.24).clamp(58.0, 86.0);
        final double titleFontSize = (availableHeight * 0.10).clamp(16.0, 20.0);
        final double subtitleFontSize = (availableHeight * 0.075).clamp(12.0, 17.0);

        return Container(
          constraints: BoxConstraints(minHeight: 220.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28.r),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0E2A66),
                Color(0xFF07204A),
                Color(0xFF04142F),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A1C3F).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28.r),
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
                              color: const Color(0xFFD7E5FF),
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18.r),
                              child: Image.asset(
                                AppAssets.femaleIcon,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(
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
                        color: const Color(0xFFE91E1E),
                        icon: Icons.call_end_rounded,
                        label: 'Not now',
                        onTap: onDeclineTapped,
                        size: actionButtonSize,
                      ),
                      _ActionCircleButton(
                        color: const Color(0xFF1FE64A),
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

  const _WaitingCallView({
    super.key,
    required this.onStopWaitingTapped,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : 260.h;
        final double topBlockHeight = availableHeight * 0.70;
        final double loaderSize = (availableHeight * 0.17).clamp(28.0, 42.0);
        final double titleFontSize = (availableHeight * 0.095).clamp(16.0, 20.0);
        final double subtitleFontSize = (availableHeight * 0.062).clamp(11.0, 13.0);

        return Container(
          constraints: BoxConstraints(minHeight: 220.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28.r),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0E2A66),
                Color(0xFF07204A),
                Color(0xFF04142F),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A1C3F).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: topBlockHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.progressiveDots(
                      color: AppColors.white,
                      size: loaderSize,
                    ),
                    SizedBox(height: 14.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Waiting for the next call',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'We will show the pickup view as soon as a call comes in.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onStopWaitingTapped,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.45),
                      width: 1.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'Cancel waiting',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CallTypeTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final IconData iconData;
  final VoidCallback onTap;
  final Color selectedTint;

  const _CallTypeTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.onTap,
    required this.selectedTint,
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
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: selected ? selectedTint : AppColors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: selected ? AppColors.primaryColor : const Color(0xFFE7EBF3),
              width: selected ? 1.5.w : 1.w,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 18.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryColor : AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.primaryColor : const Color(0xFFD1D5DB),
                      width: 1.2.w,
                    ),
                  ),
                  child: selected
                      ? Icon(
                          Icons.check,
                          color: AppColors.white,
                          size: 11.sp,
                        )
                      : null,
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconData,
                        color: AppColors.white,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
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
              child: Icon(
                icon,
                color: AppColors.white,
                size: size * 0.42,
              ),
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

  const _StreakBand({
    required this.width,
    required this.angle,
  });

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
