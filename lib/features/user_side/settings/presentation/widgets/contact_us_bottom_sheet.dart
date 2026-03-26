import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

class ContactUsBottomSheetPresenter {
  ContactUsBottomSheetPresenter._();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ContactUsBottomSheet(),
    );
  }
}

class ContactUsBottomSheet extends StatelessWidget {
  const ContactUsBottomSheet({super.key});

  static const String _whatsAppImageUrl =
      'https://cdn-icons-png.flaticon.com/512/733/733585.png';

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
                color: AppColors.contactIcon.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: _WhatsAppImage(imageUrl: _whatsAppImageUrl, size: 52.w),
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
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 24.h),
            _WhatsAppContactButton(
              imageUrl: _whatsAppImageUrl,
              onPressed: () {},
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppTexts.close,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhatsAppContactButton extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onPressed;

  const _WhatsAppContactButton({
    required this.imageUrl,
    required this.onPressed,
  });

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
            _WhatsAppImage(
              imageUrl: imageUrl,
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

class _WhatsAppImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Color? tintColor;

  const _WhatsAppImage({
    required this.imageUrl,
    required this.size,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: size,
      height: size,
      color: tintColor,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) {
        return Icon(
          Icons.chat_rounded,
          size: size,
          color: tintColor ?? AppColors.contactIcon,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return SizedBox(
          width: size,
          height: size,
          child: Center(
            child: SizedBox(
              width: size * 0.5,
              height: size * 0.5,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  tintColor ?? AppColors.contactIcon,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
