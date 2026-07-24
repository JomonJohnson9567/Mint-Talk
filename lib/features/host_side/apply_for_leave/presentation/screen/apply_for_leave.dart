import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/presentation/cubit/apply_for_leave_cubit.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/presentation/cubit/apply_for_leave_state.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/presentation/widgets/apply_for_leave_body.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/presentation/widgets/leave_history_list.dart';

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
          appBar: const CustomAppBar(
            title: 'Apply for Leave',
            automaticallyImplyLeading: true,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: const [
                    Tab(text: 'Request'),
                    Tab(text: 'History'),
                  ],
                ),
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
