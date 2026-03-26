import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';

class SettingsActionBottomSheetPresenter {
  SettingsActionBottomSheetPresenter._();

  static Future<void> showLogout(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return _show(
      context,
      child: SettingsActionBottomSheet(
        icon: Icons.logout_rounded,
        iconColor: AppColors.favIcon,
        iconBackgroundColor: AppColors.favIcon.withValues(alpha: 0.12),
        title: AppTexts.logout,
        description: AppTexts.logoutDescription,
        actionText: AppTexts.logout,
        secondaryText: AppTexts.stayLoggedIn,
        onConfirm: onConfirm,
      ),
    );
  }

  static Future<void> showDeleteAccount(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return _show(
      context,
      child: SettingsActionBottomSheet(
        icon: Icons.delete_forever_rounded,
        iconColor: AppColors.favIcon,
        iconBackgroundColor: AppColors.favIcon.withValues(alpha: 0.12),
        title: AppTexts.deleteAccount,
        description: AppTexts.deleteAccountDescription,
        actionText: AppTexts.deleteAccount,
        secondaryText: AppTexts.keepAccount,
        onConfirm: onConfirm,
      ),
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required Widget child,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => child,
    );
  }
}

class SettingsActionBottomSheet extends StatelessWidget {
  static const Color _dangerColor = AppColors.favIcon;

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String description;
  final String actionText;
  final String secondaryText;
  final VoidCallback onConfirm;

  const SettingsActionBottomSheet({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.description,
    required this.actionText,
    required this.secondaryText,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border(
            top: BorderSide(color: _dangerColor.withValues(alpha: 0.18)),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(20),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: _dangerColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    iconBackgroundColor,
                    _dangerColor.withValues(alpha: 0.2),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _dangerColor.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 42.sp),
            ),
            SizedBox(height: 18.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _dangerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                'Confirm Action',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: _dangerColor,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: _dangerColor,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 24.h),
            PrimaryButton(
              text: actionText,
              backgroundColor: _dangerColor,
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: _dangerColor,
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              child: Text(
                secondaryText,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _dangerColor.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
