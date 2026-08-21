import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:url_launcher/url_launcher.dart';

class HostContactUsBottomSheetPresenter {
  HostContactUsBottomSheetPresenter._();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HostContactUsBottomSheet(),
    );
  }
}

class HostContactUsBottomSheet extends StatelessWidget {
  const HostContactUsBottomSheet({super.key});

  static const String _whatsAppLogoUrl =
      'https://cdn-icons-png.flaticon.com/512/733/733585.png';
  static const String _supportNumber = '919876543210';
  static const String _supportMessage =
      'Hi MintTalk support, I need help with my host account.';

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
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
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
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              width: 88.w,
              height: 88.w,
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: AppColors.contactIcon.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: _WhatsAppLogo(imageUrl: _whatsAppLogoUrl, size: 52.w),
            ),
            SizedBox(height: 18.h),
            Text(
              AppTexts.contactUsTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              AppTexts.contactUsDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color: AppColors.subtitleText,
              ),
            ),
            SizedBox(height: 24.h),
            _WhatsAppButton(
              logoUrl: _whatsAppLogoUrl,
              onPressed: () => _openWhatsApp(context),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppTexts.close,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.subtitleText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final uri = Uri.parse(
      'https://wa.me/$_supportNumber?text=${Uri.encodeComponent(_supportMessage)}',
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open WhatsApp.')));
    }
  }
}

class _WhatsAppButton extends StatelessWidget {
  final String logoUrl;
  final VoidCallback onPressed;

  const _WhatsAppButton({required this.logoUrl, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.contactIcon,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _WhatsAppLogo(
              imageUrl: logoUrl,
              size: 22.w,
              tintColor: AppColors.white,
            ),
            SizedBox(width: 10.w),
            Flexible(
              child: Text(
                AppTexts.contactUsButton,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhatsAppLogo extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Color? tintColor;

  const _WhatsAppLogo({
    required this.imageUrl,
    required this.size,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      color: tintColor,
      fit: BoxFit.contain,
      errorWidget: (context, url, error) {
        return Icon(
          Icons.chat_rounded,
          size: size,
          color: tintColor ?? AppColors.contactIcon,
        );
      },
    );
  }
}
