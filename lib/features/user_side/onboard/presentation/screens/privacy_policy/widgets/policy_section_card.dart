import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/terms_and_conditions.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Cream-white, tap-to-expand card for one numbered terms section.
class PolicySectionCard extends StatefulWidget {
  const PolicySectionCard({
    super.key,
    required this.section,
    this.initiallyExpanded = false,
  });

  final TermsSection section;
  final bool initiallyExpanded;

  @override
  State<PolicySectionCard> createState() => _PolicySectionCardState();
}

class _PolicySectionCardState extends State<PolicySectionCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final section = widget.section;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18.cw),
        border: Border.all(color: AppColors.profileDivider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(18.cw),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: EdgeInsets.all(14.cw),
                child: Row(
                  children: [
                    _NumberBadge(number: section.number),
                    SizedBox(width: 12.cw),
                    Expanded(
                      child: Text(
                        section.title,
                        style: GoogleFonts.nunito(
                          fontSize: 16.csp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.plumDeep,
                          height: 1.25,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.cw),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22.csp,
                        color: AppColors.plumMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(14.cw, 0, 14.cw, 16.cw),
                      child: _SectionBody(blocks: section.blocks),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int number;

  const _NumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34.cw,
      height: 34.cw,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.videoCardBg,
        borderRadius: BorderRadius.circular(11.cw),
      ),
      child: Text(
        number.toString().padLeft(2, '0'),
        style: GoogleFonts.nunito(
          fontSize: 13.csp,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final List<TermsBlock> blocks;

  const _SectionBody({required this.blocks});

  @override
  Widget build(BuildContext context) {
    final bodyStyle = TextStyle(
      fontSize: 14.csp,
      color: AppColors.plumMuted,
      height: 1.55,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, block) in blocks.indexed) ...[
          if (i > 0) SizedBox(height: 10.cw),
          switch (block) {
            TermsParagraph(:final text) => Text(text, style: bodyStyle),
            TermsDefinition(:final term, :final text) => Text.rich(
              TextSpan(
                style: bodyStyle,
                children: [
                  TextSpan(
                    text: '$term: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.plumDeep,
                    ),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
            TermsBullets(:final items) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in items)
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.cw),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6.cw,
                          height: 6.cw,
                          margin: EdgeInsets.only(top: 8.cw, right: 10.cw),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.55,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(child: Text(item, style: bodyStyle)),
                      ],
                    ),
                  ),
              ],
            ),
          },
        ],
      ],
    );
  }
}
