import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_icons.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/gender_selection_section.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/birthday_picker_sheet.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/setup_text_field.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_header.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_mascot_hero.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_progress_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/profile_cubit.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/profile_state.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_warning.dart';

class SetupContents extends StatelessWidget {
  const SetupContents({super.key});

  // Mirrors the FullName value object's minimum length.
  static const int _minNameLength = 5;
  static const int _requiredFields = 3;

  static bool _nameDone(ProfileState s) =>
      s.name.trim().length >= _minNameLength;

  static int _completedFields(ProfileState s) => [
    _nameDone(s),
    s.dob.isNotEmpty,
    s.gender.isNotEmpty,
  ].where((done) => done).length;

  /// What the mascot says, following the user down the form.
  static String _mascotLine(ProfileState s) {
    if (s.fieldErrors.isNotEmpty) return AppTexts.mascotFixErrors;
    if (!_nameDone(s)) return AppTexts.mascotAskName;
    if (s.dob.isEmpty) {
      final firstName = s.name.trim().split(RegExp(r'\s+')).first;
      return '${AppTexts.mascotGreeting(firstName)} '
          '${AppTexts.mascotAskBirthday}';
    }
    if (s.gender.isEmpty) return AppTexts.mascotAskGender;
    return AppTexts.mascotAllSet;
  }

  @override
  Widget build(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      child: Form(
        key: profileCubit.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Wordmark(),

            // Mascot + progress follow the whole form state.
            BlocBuilder<ProfileCubit, ProfileState>(
              buildWhen: (p, c) =>
                  _mascotLine(p) != _mascotLine(c) ||
                  _completedFields(p) != _completedFields(c),
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileMascotHero(message: _mascotLine(state)),
                    SizedBox(height: 8.h),
                    ProfileProgressBar(
                      completed: _completedFields(state),
                      total: _requiredFields,
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20.h),
            const ProfileHeader(),
            SizedBox(height: 24.h),

            // Full Name
            BlocBuilder<ProfileCubit, ProfileState>(
              buildWhen: (p, c) =>
                  p.name != c.name ||
                  p.fieldErrors['fullName'] != c.fieldErrors['fullName'],
              builder: (context, state) {
                return SetupTextField(
                  label: AppTexts.fullName,
                  hintText: AppTexts.enteryourName,
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  suffixIcon: AnimatedScale(
                    scale: _nameDone(state) ? 1 : 0,
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      AppIcons.checkCircle,
                      color: AppColors.onlineIndicator,
                    ),
                  ),
                  onChanged: profileCubit.nameChanged,
                  errorText: state.fieldErrors['fullName'],
                  initialValue: state.name,
                );
              },
            ),
            SizedBox(height: 18.h),

            // Date of Birth
            BlocBuilder<ProfileCubit, ProfileState>(
              buildWhen: (p, c) =>
                  p.dob != c.dob ||
                  p.fieldErrors['dob'] != c.fieldErrors['dob'],
              builder: (context, state) {
                return SetupTextField(
                  key: ValueKey(state.dob),
                  label: AppTexts.dateOfBirth,
                  hintText: AppTexts.dobFormat,
                  prefixIcon: Icons.cake_outlined,
                  suffixIcon: Icon(
                    AppIcons.calendar,
                    color: AppColors.plumMuted,
                  ),
                  readOnly: true,
                  initialValue: state.dob,
                  errorText: state.fieldErrors['dob'],
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    BirthdayPickerSheet.show(
                      context: context,
                      currentDob: state.dob,
                      onDateSelected: profileCubit.dobChanged,
                    );
                  },
                );
              },
            ),
            SizedBox(height: 24.h),

            // Gender Selection
            BlocBuilder<ProfileCubit, ProfileState>(
              buildWhen: (p, c) =>
                  p.gender != c.gender ||
                  p.fieldErrors['gender'] != c.fieldErrors['gender'],
              builder: (context, state) {
                return GenderSelectionSection(
                  selectedGender: state.gender,
                  onSelect: (gender) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    profileCubit.genderChanged(gender);
                  },
                  errorText: state.fieldErrors['gender'],
                );
              },
            ),
            SizedBox(height: 16.h),

            const ProfileWarning(),
            SizedBox(height: 24.h),

            // Submit Button
            BlocBuilder<ProfileCubit, ProfileState>(
              buildWhen: (p, c) => p.submissionStatus != c.submissionStatus,
              builder: (context, state) {
                final isSubmitting =
                    state.submissionStatus ==
                    ProfileSubmissionStatus.submitting;

                return PrimaryButton(
                  text: AppTexts.continueText,
                  height: 48.h,
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  disabledBackgroundColor: AppColors.primaryColor.withValues(
                    alpha: 0.22,
                  ),
                  disabledForegroundColor: AppColors.plumMuted,
                  isLoading: isSubmitting,
                  onPressed: isSubmitting
                      ? null
                      : () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          profileCubit.submit();
                        },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// "MintTalk" wordmark, matching the OTP screen's top bar. No back button —
/// the OTP screen clears the stack on the way here.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: Center(
        child: Text(
          AppTexts.appName,
          style: GoogleFonts.nunito(
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.plumDeep,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
