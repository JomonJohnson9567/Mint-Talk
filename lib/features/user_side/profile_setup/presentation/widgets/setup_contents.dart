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
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/profile_cubit.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/profile_state.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/referral_cubit.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/referral_state.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_warning.dart';

class SetupContents extends StatelessWidget {
  const SetupContents({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();
    final referralCubit = context.read<ReferralCubit>();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Form(
        key: profileCubit.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10.h),
            const ProfileLogo(),
            SizedBox(height: 30.h),
            const ProfileHeader(),
            SizedBox(height: 32.h),
            
            // Full Name
            BlocBuilder<ProfileCubit, ProfileState>(
              buildWhen: (p, c) => p.name != c.name || p.fieldErrors['fullName'] != c.fieldErrors['fullName'],
              builder: (context, state) {
                return ProfileField(
                  label: AppTexts.fullName,
                  hintText: AppTexts.enteryourName,
                  suffixIcon: state.name.length >= 5
                      ? Icon(AppIcons.checkCircle, color: AppColors.green)
                      : null,
                  onChanged: profileCubit.nameChanged,
                  errorText: state.fieldErrors['fullName'],
                  initialValue: state.name,
                );
              },
            ),
            SizedBox(height: 20.h),
            
            // Date of Birth
            BlocBuilder<ProfileCubit, ProfileState>(
              buildWhen: (p, c) => p.dob != c.dob || p.fieldErrors['dob'] != c.fieldErrors['dob'],
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
                  errorText: state.fieldErrors['dob'],
                  onTap: () {
                    DobPickerBottomSheet.show(
                      context: context,
                      currentDob: state.dob,
                      onDateSelected: profileCubit.dobChanged,
                    );
                  },
                );
              },
            ),
            SizedBox(height: 20.h),
            
            // Referral Code
            BlocBuilder<ReferralCubit, ReferralState>(
              builder: (context, state) {
                Widget? suffix;
                String? apiError;
                
                if (state is ReferralLoading) {
                  suffix = const SizedBox(
                    width: 20, height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  );
                } else if (state is ReferralValid) {
                  suffix = Icon(AppIcons.checkCircle, color: AppColors.green);
                } else if (state is ReferralInvalid) {
                  suffix = Icon(AppIcons.error, color: AppColors.red);
                  apiError = state.message;
                }

                return BlocBuilder<ProfileCubit, ProfileState>(
                  buildWhen: (p, c) => 
                      p.referralCode != c.referralCode ||
                      p.fieldErrors['referralCode'] != c.fieldErrors['referralCode'],
                  builder: (context, pState) {
                    final error = pState.fieldErrors['referralCode'] ?? apiError;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileField(
                          label: AppTexts.referralCodeOptional,
                          hintText: AppTexts.enterCode,
                          initialValue: pState.referralCode,
                          suffixIcon: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: suffix,
                          ),
                          errorText: error,
                          onChanged: (value) {
                            profileCubit.referralCodeChanged(value);
                            referralCubit.onReferralCodeChanged(value);
                          },
                        ),
                        if (state is ReferralValid)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h, left: 16.w),
                            child: Text(
                              state.message, 
                              style: const TextStyle(color: AppColors.green, fontSize: 12)
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
            
            SizedBox(height: 32.h),
            
            // Gender Selection
            BlocBuilder<ProfileCubit, ProfileState>(
              buildWhen: (p, c) => p.gender != c.gender || p.fieldErrors['gender'] != c.fieldErrors['gender'],
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GenderSelectionSection(
                      selectedGender: state.gender,
                      onSelect: profileCubit.genderChanged,
                    ),
                    if (state.fieldErrors['gender'] != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h, left: 16.w),
                        child: Text(
                          state.fieldErrors['gender']!,
                          style: TextStyle(color: Colors.red, fontSize: 12.sp),
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
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                return PrimaryButton(
                  text: AppTexts.submit,
                  isLoading: state.submissionStatus == ProfileSubmissionStatus.submitting,
                  onPressed: state.submissionStatus == ProfileSubmissionStatus.submitting 
                      ? null 
                      : profileCubit.submit,
                );
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
