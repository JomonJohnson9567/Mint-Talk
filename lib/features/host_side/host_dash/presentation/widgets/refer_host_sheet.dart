import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/transitions/cubit/snack_bar_state.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/core/widgets/top_snackbar.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_cubit.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_state.dart';

/// Bottom sheet that shows the host's referral code, the reward terms, a
/// share button (system share sheet with a greeting + code) and a copy button.
class ReferHostSheet extends StatelessWidget {
  const ReferHostSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.selectionClick();
    // The modal route sits above the host shell, so hand the cubit over
    // explicitly rather than relying on it being an ancestor of the sheet.
    final profileCubit = context.read<HostProfileCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: profileCubit,
        child: const ReferHostSheet(),
      ),
    );
  }

  Future<void> _copy(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    HapticFeedback.lightImpact();
    showTopSnackBar(
      context,
      AppTexts.referralCodeCopied,
      type: SnackBarType.success,
    );
  }

  /// Opens the system share sheet (WhatsApp, Telegram, SMS…) with a greeting
  /// and the referral code pre-filled.
  Future<void> _share(BuildContext context, String code) async {
    HapticFeedback.selectionClick();
    // iPad presents the share sheet as a popover and needs an anchor rect.
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: AppTexts.hostReferralShareMessage(code),
          subject: AppTexts.hostReferralShareSubject,
          sharePositionOrigin: origin,
        ),
      );
    } catch (e, st) {
      debugPrint('ReferHostSheet share failed: $e\n$st');
      if (!context.mounted) return;
      showTopSnackBar(
        context,
        AppTexts.referralShareFailed,
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: AppColors.plumDeep.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20.cw, 10.cw, 20.cw, 16.cw),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.cw,
              height: 4.cw,
              decoration: BoxDecoration(
                color: AppColors.lavenderBorder,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 14.cw),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                // Matches the mascot image's opaque background.
                color: AppColors.hostPromoBanner,
                borderRadius: BorderRadius.circular(22.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 8.cw),
              child: Image.asset(
                AppAssets.hostEarnMascot,
                height: 110.cw,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 16.cw),
            Text(
              AppTexts.referAHost,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
            SizedBox(height: 8.cw),
            Text(
              AppTexts.referHostInfo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.csp,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: AppColors.plumMuted,
              ),
            ),
            SizedBox(height: 18.cw),
            BlocBuilder<HostProfileCubit, HostProfileState>(
              buildWhen: (previous, current) =>
                  previous.referralCode != current.referralCode,
              builder: (context, state) {
                final hasCode = state.hasReferralCode;
                return Column(
                  children: [
                    Text(
                      AppTexts.yourReferralCode,
                      style: TextStyle(
                        fontSize: 12.5.csp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.hostSubtitle,
                      ),
                    ),
                    SizedBox(height: 6.cw),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.cw),
                      decoration: BoxDecoration(
                        color: AppColors.hostPromoBanner,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.hostVideoAccent.withValues(
                            alpha: 0.5,
                          ),
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: SelectableText(
                        state.displayReferralCode,
                        style: TextStyle(
                          fontSize: hasCode ? 22.csp : 15.csp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: hasCode ? 3 : 0,
                          color: hasCode
                              ? AppColors.primaryColor
                              : AppColors.hostSubtitle,
                        ),
                      ),
                    ),
                    SizedBox(height: 18.cw),
                    Builder(
                      // Own context so the iPad popover anchors to the button.
                      builder: (buttonContext) => PrimaryButton(
                        text: AppTexts.shareReferralCode,
                        height: 52.cw,
                        trailingIcon: Icons.share_rounded,
                        textStyle: TextStyle(
                          fontSize: 16.csp,
                          fontWeight: FontWeight.w700,
                        ),
                        onPressed: hasCode
                            ? () => _share(
                                buttonContext,
                                state.displayReferralCode,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 8.cw),
                    TextButton.icon(
                      onPressed: hasCode
                          ? () => _copy(context, state.displayReferralCode)
                          : null,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        minimumSize: Size(double.infinity, 44.cw),
                        textStyle: TextStyle(
                          fontSize: 14.5.csp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      icon: Icon(Icons.copy_rounded, size: 18.cw),
                      label: const Text(AppTexts.copyReferralCode),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
