import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/cubit/profile_info_cubit.dart';

/// Peach banner that starts the host application flow.
class BecomeHostBanner extends StatelessWidget {
  const BecomeHostBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18.cw);

    return Material(
      color: AppColors.audioCardBg,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onTap(context),
        child: Stack(
          children: [
            Positioned(
              right: -24.cw,
              bottom: -40.cw,
              child: Container(
                width: 90.cw,
                height: 90.cw,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
            Positioned(
              right: 46.cw,
              top: 10.cw,
              child: Icon(
                Icons.auto_awesome,
                size: 18.csp,
                color: AppColors.audioAccent.withValues(alpha: 0.35),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 14.cw),
              child: Row(
                children: [
                  Container(
                    width: 48.cw,
                    height: 48.cw,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withValues(alpha: 0.75),
                    ),
                    child: Text('👑', style: TextStyle(fontSize: 24.csp)),
                  ),
                  SizedBox(width: 14.cw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTexts.becomeAHost,
                          style: GoogleFonts.nunito(
                            fontSize: 19.csp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.plumDeep,
                          ),
                        ),
                        Text(
                          AppTexts.becomeAHostSubtitle,
                          style: TextStyle(
                            fontSize: 13.csp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.plumMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 28.csp,
                    color: AppColors.plumDeep,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    try {
      await context.read<ProfileInfoCubit>().handleApplyHostTap();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to continue. Please try again.'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }
}
