import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/user_profile_edit/presentation/cubit/user_profile_edit_cubit.dart';
import 'package:mint_talk/features/user_side/user_profile_edit/presentation/cubit/user_profile_edit_state.dart';
import 'package:mint_talk/features/user_side/user_profile_edit/presentation/widgets/user_profile_edit_contents.dart';
import 'package:mint_talk/features/user_side/user_profile_edit/presentation/widgets/user_profile_edit_skeleton.dart';

class UserProfileEdit extends StatelessWidget {
  const UserProfileEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<UserProfileEditCubit, UserProfileEditState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == UserProfileEditStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppTexts.profileUpdated),
                  backgroundColor: AppColors.onlineIndicator,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop(true);
            } else if (state.status == UserProfileEditStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == UserProfileEditStatus.initial ||
                state.status == UserProfileEditStatus.loading) {
              return const UserProfileEditSkeleton();
            }
            return const UserProfileEditContents();
          },
        ),
      ),
    );
  }
}
