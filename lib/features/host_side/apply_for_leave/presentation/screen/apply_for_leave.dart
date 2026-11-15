import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/presentation/cubit/apply_for_leave_cubit.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/presentation/cubit/apply_for_leave_state.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/presentation/widgets/apply_for_leave_body.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/presentation/widgets/leave_history_list.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_segmented_toggle.dart';

class ApplyForLeave extends StatelessWidget {
  const ApplyForLeave({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApplyForLeaveCubit, ApplyForLeaveState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ApplyForLeaveStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Leave application submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.status == ApplyForLeaveStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.homeBackground,
          appBar: const CustomAppBar(
            title: AppTexts.leaveRequest,
            automaticallyImplyLeading: true,
            foregroundColor: AppColors.plumDeep,
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.cw, 4.cw, 20.cw, 0),
                child: const _LeaveTabsToggle(),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    ApplyForLeaveBody(),
                    LeaveHistoryList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Request/History toggle driven by the surrounding [DefaultTabController],
/// so it stays in sync with swipes on the [TabBarView].
class _LeaveTabsToggle extends StatelessWidget {
  const _LeaveTabsToggle();

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => HostSegmentedToggle(
        labels: const [AppTexts.leaveRequestTab, AppTexts.leaveHistoryTab],
        selectedIndex: controller.index,
        onChanged: controller.animateTo,
      ),
    );
  }
}
