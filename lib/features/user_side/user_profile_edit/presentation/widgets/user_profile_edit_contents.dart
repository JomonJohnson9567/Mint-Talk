import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/back_title_header.dart';
import 'package:mint_talk/features/user_side/user_profile_edit/presentation/cubit/user_profile_edit_cubit.dart';
import 'package:mint_talk/features/user_side/user_profile_edit/presentation/cubit/user_profile_edit_state.dart';

import 'user_profile_edit_account_card.dart';
import 'user_profile_edit_hero_card.dart';
import 'user_profile_edit_name_field.dart';
import 'user_profile_edit_save_bar.dart';

class UserProfileEditContents extends StatelessWidget {
  const UserProfileEditContents({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UserProfileEditCubit>();
    return BlocBuilder<UserProfileEditCubit, UserProfileEditState>(
      builder: (context, state) => Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 24.cw),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const BackTitleHeader(
                    title: AppTexts.editProfile,
                    subtitle: AppTexts.editProfileSubtitle,
                  ),
                  SizedBox(height: 18.cw),
                  UserProfileEditHeroCard(
                    imagePath: state.imagePath,
                    fullName: state.fullName,
                    onImageChanged: cubit.imageChanged,
                  ),
                  SizedBox(height: 22.cw),
                  const _SectionTitle(AppTexts.personalDetails),
                  SizedBox(height: 10.cw),
                  _SectionCard(
                    child: UserProfileEditNameField(
                      name: state.fullName,
                      errorText: state.fieldErrors['fullName'],
                      onChanged: cubit.fullNameChanged,
                    ),
                  ),
                  SizedBox(height: 22.cw),
                  const _SectionTitle(AppTexts.accountDetails),
                  SizedBox(height: 10.cw),
                  UserProfileEditAccountCard(
                    phone: state.phone,
                    dob: state.dob,
                    gender: state.gender,
                    dobError: state.fieldErrors['dob'],
                  ),
                ],
              ),
            ),
          ),
          const UserProfileEditSaveBar(),
        ],
      ),
    );
  }
}

/// Nunito heading shown above each section card.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.cw),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 18.csp,
          fontWeight: FontWeight.w800,
          color: AppColors.plumDeep,
        ),
      ),
    );
  }
}

/// Cream-white rounded card wrapping the editable fields.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.cw),
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
      child: child,
    );
  }
}
