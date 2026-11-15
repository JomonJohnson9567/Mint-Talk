import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import '../cubit/host_profile_edit_cubit.dart';
import '../cubit/host_profile_edit_state.dart';
import '../widgets/host_profile_edit_contents.dart';
import '../widgets/host_profile_edit_skeleton.dart';

class HostProfileEdit extends StatelessWidget {
  const HostProfileEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<HostProfileEditCubit, HostProfileEditState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == HostProfileEditStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppTexts.profileUpdated),
                  backgroundColor: AppColors.onlineIndicator,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop(true);
            } else if (state.status == HostProfileEditStatus.failure &&
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
            if (state.status == HostProfileEditStatus.loading ||
                state.status == HostProfileEditStatus.initial) {
              return const HostProfileEditSkeleton();
            }
            return const HostProfileEditContents();
          },
        ),
      ),
    );
  }
}
