import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/transitions/cubit/snack_bar_state.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/top_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

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
  // wa.me expects the number with country code and no '+'.
  static const String _supportNumber = '918921355574';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.cw, 12.cw, 20.cw, 24.cw),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.cw)),
          border: const Border(
            top: BorderSide(color: AppColors.profileDivider),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44.cw,
              height: 5.cw,
              decoration: BoxDecoration(
                color: AppColors.lavenderBorder,
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
            SizedBox(height: 20.cw),
            const _SupportBadge(whatsAppImageUrl: _whatsAppImageUrl),
            SizedBox(height: 18.cw),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.cw, vertical: 6.cw),
              decoration: BoxDecoration(
                color: AppColors.popularCardBg,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                AppTexts.contactUsChip,
                style: TextStyle(
                  fontSize: 12.csp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.linkMagenta,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            SizedBox(height: 14.cw),
            Text(
              AppTexts.contactUsTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
            SizedBox(height: 10.cw),
            Text(
              AppTexts.contactUsDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.csp,
                height: 1.5,
                color: AppColors.plumMuted,
              ),
            ),
            SizedBox(height: 24.cw),
            _WhatsAppContactButton(
              imageUrl: _whatsAppImageUrl,
              onPressed: () => _openWhatsApp(context),
            ),
            SizedBox(height: 12.cw),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: 18.cw,
                  vertical: 8.cw,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              child: Text(
                AppTexts.close,
                style: TextStyle(
                  fontSize: 14.csp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.plumMuted,
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
      'https://wa.me/$_supportNumber'
      '?text=${Uri.encodeComponent(AppTexts.contactUsWhatsAppMessage)}',
    );

    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}

    if (!context.mounted) return;
    if (launched) {
      Navigator.of(context).pop();
    } else {
      showTopSnackBar(
        context,
        AppTexts.whatsAppOpenFailed,
        type: SnackBarType.error,
      );
    }
  }
}

/// Plum support badge with a small WhatsApp logo pinned to its corner.
class _SupportBadge extends StatelessWidget {
  final String whatsAppImageUrl;

  const _SupportBadge({required this.whatsAppImageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88.cw,
      height: 88.cw,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 88.cw,
            height: 88.cw,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.popularCardBg, AppColors.videoCardBg],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lavenderBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: AppColors.primaryColor,
              size: 42.csp,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 30.cw,
              height: 30.cw,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.profileDivider),
              ),
              child: _WhatsAppImage(imageUrl: whatsAppImageUrl, size: 18.cw),
            ),
          ),
        ],
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
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(horizontal: 20.cw, vertical: 16.cw),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _WhatsAppImage(
              imageUrl: imageUrl,
              size: 22.cw,
              tintColor: AppColors.white,
            ),
            SizedBox(width: 10.cw),
            Flexible(
              child: Text(
                AppTexts.contactUsButton,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.csp, fontWeight: FontWeight.w700),
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
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      color: tintColor,
      fit: BoxFit.contain,
      errorWidget: (_, _, _) {
        return Icon(
          Icons.chat_rounded,
          size: size,
          color: tintColor ?? AppColors.primaryColor,
        );
      },
      placeholder: (context, url) {
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
                  tintColor ?? AppColors.primaryColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
