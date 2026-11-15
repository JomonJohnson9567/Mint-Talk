import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/back_title_header.dart';
import '../cubit/host_profile_edit_cubit.dart';
import '../cubit/host_profile_edit_state.dart';
import 'host_profile_edit_account_card.dart';
import 'host_profile_edit_categories.dart';
import 'host_profile_edit_hero_card.dart';
import 'host_profile_edit_name_field.dart';
import 'host_profile_edit_save_bar.dart';

class HostProfileEditContents extends StatelessWidget {
  const HostProfileEditContents({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HostProfileEditCubit>();
    return BlocBuilder<HostProfileEditCubit, HostProfileEditState>(
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
                  HostProfileEditHeroCard(
                    avatarAsset: state.avatarAsset,
                    fullName: state.name,
                    onAvatarChanged: cubit.avatarChanged,
                  ),
                  SizedBox(height: 22.cw),
                  const _SectionTitle(AppTexts.personalDetails),
                  SizedBox(height: 10.cw),
                  _SectionCard(
                    child: HostProfileEditNameField(
                      name: state.name,
                      errorText: state.nameError,
                      onChanged: cubit.nameChanged,
                    ),
                  ),
                  SizedBox(height: 22.cw),
                  const _SectionTitle(AppTexts.preferredCategoriesTitle),
                  SizedBox(height: 10.cw),
                  _SectionCard(
                    child: HostProfileEditCategories(
                      selected: state.selectedCategories,
                      onToggle: cubit.toggleCategory,
                    ),
                  ),
                  SizedBox(height: 22.cw),
                  const _SectionTitle(AppTexts.accountDetails),
                  SizedBox(height: 10.cw),
                  HostProfileEditAccountCard(
                    phone: state.phone,
                    idNumber: state.idNumber,
                    dob: state.dob,
                    gender: state.gender,
                  ),
                ],
              ),
            ),
          ),
          const HostProfileEditSaveBar(),
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
