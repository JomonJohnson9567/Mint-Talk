import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';

/// Sticky Decline / Agree bar. Pops `false` / `true` respectively.
class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.nunito(
      fontSize: 16.csp,
      fontWeight: FontWeight.w800,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.homeBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.plumDeep.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 12.cw),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52.cw,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.videoCardBg,
                      foregroundColor: AppColors.primaryColor,
                      side: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.2,
                      ),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(AppTexts.decline, style: labelStyle),
                  ),
                ),
              ),
              SizedBox(width: 12.cw),
              Expanded(
                flex: 3,
                child: PrimaryButton(
                  text: AppTexts.agreeAndContinue,
                  height: 52.cw,
                  textStyle: labelStyle,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
