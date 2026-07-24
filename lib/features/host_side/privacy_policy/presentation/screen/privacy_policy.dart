import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_static_content_screen.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  static const List<HostStaticContentSection> _sections = [
    HostStaticContentSection(
      title: 'Information we may collect',
      content:
          'We may collect profile details, device information, app usage data, and support messages so that the host experience can be improved over time. In a production build, this section would outline the exact data categories and retention periods.',
    ),
    HostStaticContentSection(
      title: 'How the information is used',
      content:
          'Collected information can be used to personalize the experience, improve app stability, respond to support requests, and understand how the host tools are being used.',
    ),
    HostStaticContentSection(
      title: 'Data protection',
      content:
          'MintTalk would aim to protect data through standard security practices such as access control, secure storage, and careful handling of sensitive information. This demo content is intentionally generic.',
    ),
    HostStaticContentSection(
      title: 'Your choices',
      content:
          'Users should be able to review privacy-related choices, contact support, and request assistance where required by the app or local regulations.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const HostStaticContentScreen(
      title: 'Privacy Policy',
      heroTitle: 'Privacy Policy',
      heroSubtitle:
          'Dummy policy content for the host area, laid out in a clean and readable format.',
      heroIcon: Icons.privacy_tip_rounded,
      heroColor: AppColors.contactIcon,
      sections: _sections,
      footerNote:
          'This page currently contains placeholder content and can be replaced with the final legal copy later.',
    );
  }
}
