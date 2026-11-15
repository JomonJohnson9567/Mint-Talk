import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/constants/terms_and_conditions.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/back_title_header.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/privacy_policy/widgets/action_buttons.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/privacy_policy/widgets/policy_intro_card.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/privacy_policy/widgets/policy_section_card.dart';

class TextContents extends StatelessWidget {
  const TextContents({super.key});

  @override
  Widget build(BuildContext context) {
    const sections = TermsAndConditions.sections;

    return Column(
      children: [
        Expanded(
          // Lazily built — the full terms run to 27 sections.
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 24.cw),
            itemCount: sections.length + 1,
            separatorBuilder: (_, index) =>
                SizedBox(height: index == 0 ? 18.cw : 12.cw),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BackTitleHeader(
                      title: AppTexts.termsAndConditionsLink,
                      subtitle: AppTexts.termsAndConditionsSubtitle,
                    ),
                    SizedBox(height: 18.cw),
                    const PolicyIntroCard(),
                  ],
                );
              }
              final section = sections[index - 1];
              return PolicySectionCard(
                key: ValueKey(section.number),
                section: section,
                initiallyExpanded: index == 1,
              );
            },
          ),
        ),
        const ActionButtons(),
      ],
    );
  }
}
