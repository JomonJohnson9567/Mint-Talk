import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/presentation/cubit/apply_for_leave_cubit.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/presentation/cubit/apply_for_leave_state.dart';
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

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request time off by filling in the details below',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6E7787),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 24.h),
              LeaveTypeDropdown(
                selectedType: state.leaveType,
                onChanged: cubit.changeLeaveType,
              ),
              SizedBox(height: 24.h),
              DateSelectionRow(
                startDate: state.startDate,
                endDate: state.endDate,
                onStartDateChanged: cubit.changeStartDate,
                onEndDateChanged: cubit.changeEndDate,
              ),
              SizedBox(height: 24.h),
              ReasonInputField(
                reason: state.reason,
                onChanged: cubit.changeReason,
              ),
              SizedBox(height: 24.h),
              AvailableDaysCard(
                availableDays: state.availableDays,
              ),
              SizedBox(height: 36.h),
              PrimaryButton(
                text: 'Submit',
                isLoading: state.status == ApplyForLeaveStatus.loading,
                onPressed: state.status == ApplyForLeaveStatus.loading
                    ? null
                    : () => cubit.submitLeaveRequest(),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}
