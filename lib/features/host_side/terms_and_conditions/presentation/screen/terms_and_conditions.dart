import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_static_content_screen.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  static const List<HostStaticContentSection> _sections = [
    HostStaticContentSection(
      title: 'Acceptance of terms',
      content:
          'By using MintTalk, hosts agree to follow the platform rules, community expectations, and any additional conditions that may apply to specific features or host tools.',
    ),
    HostStaticContentSection(
      title: 'Account responsibility',
      content:
          'Hosts are responsible for keeping their account details accurate and secure. Any activity performed from the account may be treated as authorized unless reported promptly.',
    ),
    HostStaticContentSection(
      title: 'Acceptable use',
      content:
          'The app should be used in a respectful, lawful, and community-friendly manner. Harassment, fraud, spam, and abuse would be prohibited in a live release of the product.',
    ),
    HostStaticContentSection(
      title: 'Service changes',
      content:
          'Features, pricing, and availability may change as the product evolves. We can update these terms to reflect new functionality, legal requirements, or support policies.',
    ),
    HostStaticContentSection(
      title: 'Support and questions',
      content:
          'If a host has questions about the terms, they should be able to reach support through the contact options in the settings screen.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const HostStaticContentScreen(
      title: 'Terms & Conditions',
      heroTitle: 'Terms & Conditions',
      heroSubtitle:
          'Placeholder legal copy for the host area with a structured and easy-to-read layout.',
      heroIcon: Icons.description_rounded,
      heroColor: AppColors.primaryColor,
      sections: _sections,
      footerNote:
          'Please replace the placeholder text with the final approved legal content before release.',
    );
  }
}
