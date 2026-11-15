import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/user_side/user_profile_edit/presentation/cubit/user_profile_edit_cubit.dart';
import 'package:mint_talk/features/user_side/user_profile_edit/presentation/cubit/user_profile_edit_state.dart';

/// Sticky bottom bar with the "Save changes" button. Sits below the scroll
/// view (not in `bottomNavigationBar`) so it rides above the keyboard, and
/// stays disabled until something has actually changed.
class UserProfileEditSaveBar extends StatelessWidget {
  const UserProfileEditSaveBar({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: BlocBuilder<UserProfileEditCubit, UserProfileEditState>(
            buildWhen: (previous, current) =>
                previous.isSaving != current.isSaving ||
                previous.hasChanges != current.hasChanges,
            builder: (context, state) {
              final canSave = state.hasChanges && !state.isSaving;
              return PrimaryButton(
                text: AppTexts.saveChanges,
                height: 52.cw,
                isLoading: state.isSaving,
                disabledBackgroundColor: AppColors.primaryColor.withValues(
                  alpha: 0.6,
                ),
                disabledForegroundColor: AppColors.white,
                textStyle: GoogleFonts.nunito(
                  fontSize: 16.csp,
                  fontWeight: FontWeight.w800,
                ),
                onPressed: canSave
                    ? () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        context.read<UserProfileEditCubit>().submit();
                      }
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
}
