import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/custom_outline_button.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import '../widgets/term_section_card.dart';

class TermsAndConditionsForHost extends StatelessWidget {
  const TermsAndConditionsForHost({super.key});

  static const List<_TermSectionModel> _sections = [
    _TermSectionModel(
      title: '1. Acceptance of Terms',
      content: 'By creating an account, accessing, or using the platform, you confirm that you are at least 18 years old or have obtained permission from a parent or legal guardian. If you do not agree with these Terms, you must discontinue use of the platform immediately.',
    ),
    _TermSectionModel(
      title: '2. User Accounts',
      content: 'Users are responsible for maintaining the confidentiality of their account credentials. You agree to provide accurate, complete, and up-to-date information during registration and to keep your information current.\n\nYou are solely responsible for all activities that occur under your account. Sharing account credentials with others is discouraged and may result in account suspension if misuse is detected.',
    ),
    _TermSectionModel(
      title: '3. User Content',
      content: 'You retain ownership of the content you create, upload, post, or share on the platform. By posting content, you grant us a non-exclusive, worldwide, royalty-free license to display, distribute, reproduce, and promote such content in connection with the operation and marketing of the platform.\n\nYou agree not to post content that:\n• Violates any applicable law or regulation.\n• Infringes intellectual property rights.\n• Contains harmful, misleading, defamatory, or offensive material.\n• Promotes illegal activities.\n• Impersonates another person or organization.',
    ),
    _TermSectionModel(
      title: '4. Community Guidelines',
      content: 'Users are expected to engage respectfully with others. Harassment, bullying, hate speech, threats, spam, or any form of abusive behavior may result in content removal, temporary suspension, or permanent account termination.\n\nWe reserve the right to investigate reports of misconduct and take appropriate action without prior notice.',
    ),
    _TermSectionModel(
      title: '5. Privacy and Data Collection',
      content: 'We may collect information such as profile details, usage statistics, device information, and communication preferences to improve our services and provide a personalized experience.\n\nBy using the platform, you consent to the collection and processing of your information in accordance with our Privacy Policy.',
    ),
    _TermSectionModel(
      title: '6. Prohibited Activities',
      content: 'Users must not:\n• Attempt to gain unauthorized access to the platform or other user accounts.\n• Use automated tools, bots, or scripts to manipulate engagement metrics.\n• Distribute malware, viruses, or harmful software.\n• Interfere with the proper functioning of the platform.\n• Use the platform for fraudulent or deceptive purposes.',
    ),
    _TermSectionModel(
      title: '7. Intellectual Property',
      content: 'All trademarks, logos, designs, software, and platform features are the property of the company or its licensors. Users may not copy, modify, distribute, or create derivative works without prior written consent.',
    ),
    _TermSectionModel(
      title: '8. Advertisements and Promotions',
      content: 'The platform may display advertisements, sponsored content, or promotional materials. We are not responsible for products, services, or offers provided by third parties. Any transactions between users and advertisers are solely at the user\'s discretion.',
    ),
    _TermSectionModel(
      title: '9. Account Suspension and Termination',
      content: 'We reserve the right to suspend, restrict, or terminate any account that violates these Terms or poses a risk to the platform, its users, or its reputation.\n\nUsers may delete their accounts at any time through the available account settings, subject to applicable data retention requirements.',
    ),
    _TermSectionModel(
      title: '10. Service Availability',
      content: 'We strive to provide uninterrupted service but do not guarantee that the platform will always be available, secure, or error-free. Maintenance, updates, technical issues, or unforeseen circumstances may result in temporary disruptions.',
    ),
    _TermSectionModel(
      title: '11. Limitation of Liability',
      content: 'To the maximum extent permitted by law, the company shall not be liable for any indirect, incidental, special, or consequential damages arising from the use or inability to use the platform, including loss of data, profits, or reputation.',
    ),
    _TermSectionModel(
      title: '12. Changes to Terms',
      content: 'We may modify these Terms and Conditions from time to time. Continued use of the platform after any changes become effective constitutes acceptance of the updated Terms.',
    ),
    _TermSectionModel(
      title: '13. Governing Law',
      content: 'These Terms shall be governed by and interpreted in accordance with the laws of the jurisdiction in which the company is registered, without regard to conflict of law principles.',
    ),
    _TermSectionModel(
      title: '14. Contact Information',
      content: 'For questions, concerns, or feedback regarding these Terms and Conditions, users may contact our support team through the official communication channels provided within the platform.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: 'Terms & Conditions',
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TermsHeader(),
                  SizedBox(height: 24.h),
                  ..._sections.map(
                    (section) => TermSectionCard(
                      title: section.title,
                      content: section.content,
                    ),
                  ),
                  const _TermsFooter(),
                ],
              ),
            ),
          ),
          const _TermsActionButtons(),
        ],
      ),
    );
  }
}

class _TermSectionModel {
  final String title;
  final String content;

  const _TermSectionModel({required this.title, required this.content});
}

class _TermsHeader extends StatelessWidget {
  const _TermsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withAlpha(13),
            AppColors.primaryColor.withAlpha(3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primaryColor.withAlpha(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TermsHeaderTitle(),
          SizedBox(height: 16.h),
          Text(
            'Welcome to our social media platform. By accessing or using the application, website, or services provided by us, you agree to comply with and be bound by the following Terms and Conditions. Please read them carefully before using the platform.',
            style: GoogleFonts.manrope(
              fontSize: 14.sp,
              color: AppColors.subtitleText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsHeaderTitle extends StatelessWidget {
  const _TermsHeaderTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.description_rounded,
            color: AppColors.primaryColor,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Host Agreement',
              style: GoogleFonts.manrope(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Last Updated: June 2026',
              style: GoogleFonts.manrope(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.subtitleText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TermsFooter extends StatelessWidget {
  const _TermsFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.h, bottom: 24.h),
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
                onPressed: () {
                  Navigator.pop(context, true);
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