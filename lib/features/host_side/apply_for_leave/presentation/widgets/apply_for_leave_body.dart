import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/presentation/cubit/apply_for_leave_cubit.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/presentation/cubit/apply_for_leave_state.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_mascot_banner.dart';
import 'available_days_card.dart';
import 'date_selection_row.dart';
import 'leave_type_dropdown.dart';
import 'reason_input_field.dart';

class ApplyForLeaveBody extends StatelessWidget {
  const ApplyForLeaveBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApplyForLeaveCubit, ApplyForLeaveState>(
      builder: (context, state) {
        final cubit = context.read<ApplyForLeaveCubit>();
        final isSubmitting = state.status == ApplyForLeaveStatus.loading;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.cw, 16.cw, 20.cw, 24.cw),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HostMascotBanner(
                title: AppTexts.takeALittleBreather,
                subtitle: AppTexts.planYourTimeAway,
                mascotAsset: AppAssets.noCallsMascot,
                mascotHeight: 96,
              ),
              SizedBox(height: 20.cw),
              LeaveTypeDropdown(
                selectedType: state.leaveType,
                onChanged: cubit.changeLeaveType,
              ),
              SizedBox(height: 18.cw),
              DateSelectionRow(
                startDate: state.startDate,
                endDate: state.endDate,
                onStartDateChanged: cubit.changeStartDate,
                onEndDateChanged: cubit.changeEndDate,
              ),
              SizedBox(height: 18.cw),
              ReasonInputField(
                reason: state.reason,
                onChanged: cubit.changeReason,
              ),
              SizedBox(height: 18.cw),
              AvailableDaysCard(availableDays: state.availableDays),
              SizedBox(height: 24.cw),
              PrimaryButton(
                text: AppTexts.submitRequest,
                backgroundColor: AppColors.primaryColor,
                height: 54.cw,
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : cubit.submitLeaveRequest,
              ),
            ],
          ),
        );
      },
    );
  }
}
