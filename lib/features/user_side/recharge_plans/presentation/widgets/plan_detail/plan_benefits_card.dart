import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

import 'plan_detail_section_card.dart';

/// "What you get" card listing what a recharge gives the user.
class PlanBenefitsCard extends StatelessWidget {
  const PlanBenefitsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PlanDetailSectionCard(
      child: Column(
        children: [
          const _BenefitRow(
            icon: Icons.flash_on_rounded,
            title: AppTexts.instantCredit,
            description: AppTexts.instantCreditDesc,
          ),
          SizedBox(height: 14.cw),
          const _BenefitRow(
            icon: Icons.lock_rounded,
            title: AppTexts.securePayment,
            description: AppTexts.securePaymentDesc,
          ),
          SizedBox(height: 14.cw),
          const _BenefitRow(
            icon: Icons.chat_bubble_rounded,
            title: AppTexts.startConversations,
            description: AppTexts.startConversationsDesc,
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.cw,
          height: 40.cw,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 19.csp),
        ),
        SizedBox(width: 12.cw),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.csp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.plumDeep,
                ),
              ),
              SizedBox(height: 2.cw),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.csp,
                  color: AppColors.plumMuted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
