import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/dob_picker_bottom_sheet.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_field.dart';
import 'package:mint_talk/features/user_side/user_profile_edit/presentation/cubit/user_profile_edit_cubit.dart';
import 'package:mint_talk/features/user_side/user_profile_edit/presentation/cubit/user_profile_edit_state.dart';

import 'user_profile_edit_avatar.dart';

class UserProfileEditContents extends StatelessWidget {
  const UserProfileEditContents({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UserProfileEditCubit>();
    return BlocBuilder<UserProfileEditCubit, UserProfileEditState>(
      builder: (context, state) => SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 36.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserProfileEditAvatar(
              imagePath: state.imagePath,
              fullName: state.fullName,
              onChanged: cubit.imageChanged,
            ),
            SizedBox(height: 16.h),
            _ProfileFormCard(state: state, cubit: cubit),
            SizedBox(height: 24.h),
            PrimaryButton(
              text: 'Save changes',
              isLoading: state.isSaving,
              onPressed: state.isSaving ? null : cubit.submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileFormCard extends StatelessWidget {
  final UserProfileEditState state;
  final UserProfileEditCubit cubit;

  const _ProfileFormCard({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: .04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal details',
            style: GoogleFonts.manrope(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Keep your profile information up to date.',
            style: GoogleFonts.manrope(
              fontSize: 13.sp,
              color: AppColors.subtitleText,
            ),
          ),
          SizedBox(height: 24.h),
          ProfileField(
            key: ValueKey('name-${state.fullName}'),
            label: 'FULL NAME',
            hintText: 'Enter your full name',
            labelColor: AppColors.primaryColor,
            initialValue: state.fullName,
            errorText: state.fieldErrors['fullName'],
            onChanged: cubit.fullNameChanged,
          ),
          SizedBox(height: 18.h),
          ProfileField(
            key: ValueKey('phone-${state.phone}'),
            label: 'PHONE NUMBER',
            hintText: 'Phone number',
            labelColor: AppColors.primaryColor,
            initialValue: state.phone,
            readOnly: true,
            suffixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.subtitleText,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Text(
              'Phone number is linked to your account.',
              style: GoogleFonts.manrope(
                fontSize: 11.sp,
                color: AppColors.subtitleText,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          ProfileField(
            key: ValueKey('dob-${state.dob}'),
            label: 'DATE OF BIRTH',
            hintText: 'DD/MM/YYYY',
            labelColor: AppColors.primaryColor,
            initialValue: state.dob,
            readOnly: true,
            errorText: state.fieldErrors['dob'],
            suffixIcon: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.subtitleText,
            ),
            onTap: () => DobPickerBottomSheet.show(
              context: context,
              currentDob: state.dob,
              onDateSelected: cubit.dobChanged,
            ),
          ),
          SizedBox(height: 18.h),
          ProfileField(
            key: ValueKey('gender-${state.gender}'),
            label: 'GENDER',
            hintText: 'Gender',
            labelColor: AppColors.primaryColor,
            initialValue: state.gender.isEmpty
                ? ''
                : '${state.gender[0].toUpperCase()}${state.gender.substring(1)}',
            readOnly: true,
            suffixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.subtitleText,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Text(
              'Gender cannot be changed after registration.',
              style: GoogleFonts.manrope(
                fontSize: 11.sp,
                color: AppColors.subtitleText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
