import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_static_content_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<HostStaticContentSection> _sections = [
    HostStaticContentSection(
      title: 'What MintTalk is about',
      content:
          'MintTalk is a live conversation platform designed to help people connect with hosts in a simple, safe, and supportive way. The app focuses on quick discovery, smooth communication, and a polished experience.',
    ),
    HostStaticContentSection(
      title: 'Why hosts use it',
      content:
          'Hosts can manage conversations, track activity, and stay connected with their audience using an interface that is easy to navigate and built for consistency across the app.',
    ),
    HostStaticContentSection(
      title: 'Version and support',
      content:
          'This demo build includes sample content for the host settings area. Future releases can surface app version details, support channels, and product updates in this section.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const HostStaticContentScreen(
      title: 'About',
      heroTitle: 'About MintTalk',
      heroSubtitle:
          'A clean, reliable space for hosts to manage their presence and stay connected with users.',
      heroIcon: Icons.info_rounded,
      heroColor: AppColors.aboutIcon,
      sections: _sections,
      footerNote:
          'Built with a focus on clarity, simple navigation, and a calm host experience.',
    );
  }
}
