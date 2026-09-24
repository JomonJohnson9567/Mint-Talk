import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/theme/color.dart';
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
          _NameField(
            name: state.fullName,
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
              Icons.lock_outline,
              color: AppColors.subtitleText,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Text(
              'Date of birth cannot be changed after registration.',
              style: GoogleFonts.manrope(
                fontSize: 11.sp,
                color: AppColors.subtitleText,
              ),
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

/// Owns the name field's [TextEditingController] itself instead of relying
/// on [ProfileField]'s `initialValue`, which only ever seeds the field on
/// its very first build. `initialValue` alone can't reflect a name arriving
/// later from the cubit's async profile load, so this used to be keyed off
/// `state.fullName` to force a remount whenever it changed — which also
/// remounted (and stole focus from) the field on every single keystroke,
/// since `onChanged` emits a new `state.fullName` on every character.
/// Syncing the controller in [didUpdateWidget] instead picks up the
/// async-loaded name without ever touching focus while typing.
class _NameField extends StatefulWidget {
  final String name;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const _NameField({
    required this.name,
    required this.errorText,
    required this.onChanged,
  });

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.name,
  );

  @override
  void didUpdateWidget(covariant _NameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only external changes (the async profile load) land here — typing
    // routes through onChanged -> cubit -> this same widget.name, so it
    // already matches _controller.text by the time this runs and this is
    // a no-op, leaving focus/cursor untouched.
    if (widget.name != _controller.text) {
      _controller.text = widget.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileField(
      label: 'FULL NAME',
      hintText: 'Enter your full name',
      labelColor: AppColors.primaryColor,
      controller: _controller,
      onChanged: widget.onChanged,
      errorText: widget.errorText,
    );
  }
}
