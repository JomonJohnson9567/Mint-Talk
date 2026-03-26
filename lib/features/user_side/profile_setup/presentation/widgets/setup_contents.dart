import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_icons.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/core/widgets/dob_picker_bottom_sheet.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/gender_selection_section.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_field.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_header.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_logo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/utils/validators.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/profile_setup_cubit.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/profile_setup_state.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_warning.dart';

class SetupContents extends StatelessWidget {
  const SetupContents({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileSetupCubit>();
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Form(
        key: cubit.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10.h),
            const ProfileLogo(),
            SizedBox(height: 30.h),
            const ProfileHeader(),
            SizedBox(height: 32.h),
            // Full Name
            BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
              buildWhen: (previous, current) => previous.name != current.name,
              builder: (context, state) {
                return ProfileField(
                  label: AppTexts.fullName,
                  hintText: AppTexts.enteryourName,
                  suffixIcon: state.name.isNotEmpty
                      ? Icon(AppIcons.checkCircle, color: AppColors.green)
                      : null,
                  onChanged: cubit.nameChanged,
                  validator: Validators.name,
                  initialValue: state.name,
                );
              },
            ),
            SizedBox(height: 20.h),
            // Date of Birth
            BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
              buildWhen: (previous, current) => previous.dob != current.dob,
              builder: (context, state) {
                return ProfileField(
                  key: ValueKey(state.dob),
                  label: AppTexts.dateOfBirth,
                  hintText: AppTexts.dobFormat,
                  suffixIcon: Icon(
                    AppIcons.calendar,
                    color: AppColors.textGrey,
                  ),
                  readOnly: true,
                  initialValue: state.dob,
                  validator: Validators.dob,
                  onTap: () {
                    DobPickerBottomSheet.show(
                      context: context,
                      currentDob: state.dob,
                      onDateSelected: cubit.dobChanged,
                    );
                  },
                );
              },
            ),
            SizedBox(height: 20.h),
            // Referral Code
            const ProfileField(
              label: AppTexts.referralCodeOptional,
              hintText: AppTexts.enterCode,
            ),
            SizedBox(height: 32.h),
            BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
              buildWhen: (previous, current) =>
                  previous.gender != current.gender ||
                  previous.genderError != current.genderError,
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GenderSelectionSection(
                      selectedGender: state.gender,
                      onSelect: cubit.genderChanged,
                    ),
                    if (state.genderError != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h, left: 16.w),
                        child: Text(
                          state.genderError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: 24.h),

            const ProfileWarning(),

            SizedBox(height: 32.h),

            // Submit Button
            PrimaryButton(text: AppTexts.submit, onPressed: cubit.submit),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
