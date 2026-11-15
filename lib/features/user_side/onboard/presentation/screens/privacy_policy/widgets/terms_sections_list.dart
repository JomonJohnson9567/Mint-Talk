import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/terms_and_conditions.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/privacy_policy/widgets/policy_intro_card.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/privacy_policy/widgets/policy_section_card.dart';

/// The MintTalk terms (intro card + every [TermsAndConditions.sections]
/// entry), built lazily. Shared by the host-application and host-settings
/// terms screens so they show exactly what the welcome screen shows.
class TermsSectionsList extends StatelessWidget {
  const TermsSectionsList({super.key, this.footer});

  /// Optional widget shown after the last section.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    const sections = TermsAndConditions.sections;
    final hasFooter = footer != null;

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.cw, 16.cw, 16.cw, 24.cw),
      itemCount: sections.length + 1 + (hasFooter ? 1 : 0),
      separatorBuilder: (_, index) =>
          SizedBox(height: index == 0 ? 18.cw : 12.cw),
      itemBuilder: (context, index) {
        if (index == 0) return const PolicyIntroCard();
        if (index > sections.length) return footer!;
        final section = sections[index - 1];
        return PolicySectionCard(
          key: ValueKey(section.number),
          section: section,
          initiallyExpanded: index == 1,
        );
      },
    );
  }
}
