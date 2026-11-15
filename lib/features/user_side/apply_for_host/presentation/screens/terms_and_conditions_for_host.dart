import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/di/injection.dart';
import '../../domain/usecases/accept_host_terms_usecase.dart';
import 'package:mint_talk/core/widgets/custom_outline_button.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/privacy_policy/widgets/terms_sections_list.dart';

class TermsAndConditionsForHost extends StatelessWidget {
  final bool readOnly;

  const TermsAndConditionsForHost({super.key, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: const CustomAppBar(
        title: 'Terms & Conditions',
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          const Expanded(child: TermsSectionsList(footer: _TermsFooter())),
          if (readOnly)
            const _TermsAgreedTag()
          else
            const _TermsActionButtons(),
        ],
      ),
    );
  }
}

class _TermsFooter extends StatelessWidget {
  const _TermsFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.onlineIndicator.withAlpha(51)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.onlineIndicator,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'By continuing to use the platform, you acknowledge that you have read, understood, and agreed to these Terms and Conditions.',
              style: GoogleFonts.manrope(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsActionButtons extends StatelessWidget {
  const _TermsActionButtons();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: CustomOutlineButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                text: 'Decline',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: PrimaryButton(
                onPressed: () async {
                  try {
                    await getIt<AcceptHostTermsUseCase>()();
                    if (context.mounted) Navigator.pop(context, true);
                  } catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not save your agreement. Please try again.',
                        ),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  }
                },
                text: 'Agree & Continue',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsAgreedTag extends StatelessWidget {
  const _TermsAgreedTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.softMint,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.onlineIndicator.withAlpha(60)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_rounded,
                color: AppColors.onlineIndicator,
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                'Agreed',
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onlineIndicator,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
