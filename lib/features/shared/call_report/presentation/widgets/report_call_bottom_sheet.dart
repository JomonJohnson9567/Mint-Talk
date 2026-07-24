import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import '../cubit/call_report_cubit.dart';
import '../cubit/call_report_state.dart';

class ReportCallBottomSheet extends StatelessWidget {
  final String callId;
  final TextEditingController descriptionController;
  final ValueNotifier<String> selectedReasonNotifier;

  ReportCallBottomSheet({
    super.key,
    required this.callId,
    TextEditingController? descriptionController,
    ValueNotifier<String>? selectedReasonNotifier,
  })  : descriptionController = descriptionController ?? TextEditingController(),
        selectedReasonNotifier = selectedReasonNotifier ?? ValueNotifier<String>('Abusive Language');

  static const List<String> reasons = [
    'Abusive Language',
    'Harassment',
    'Inappropriate Behavior',
    'Spam or Fraud',
    'Other',
  ];

  static void show(BuildContext context, {required String callId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => getIt<CallReportCubit>(),
        child: ReportCallBottomSheet(callId: callId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: BlocConsumer<CallReportCubit, CallReportState>(
        listener: (context, state) {
          if (state is CallReportSuccess) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Call reported successfully')),
            );
          } else if (state is CallReportFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is CallReportSubmitting;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderSoft,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Report Call Misconduct',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Select Reason',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 8.h),
              ValueListenableBuilder<String>(
                valueListenable: selectedReasonNotifier,
                builder: (context, selectedReason, _) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderSoft),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedReason,
                        isExpanded: true,
                        items: reasons
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r, style: TextStyle(fontSize: 14.sp)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) selectedReasonNotifier.value = val;
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.h),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Provide additional details about the incident...',
                  hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.subtitleText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.borderSoft),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          final reason = selectedReasonNotifier.value;
                          final description = descriptionController.text.trim();
                          if (description.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a description')),
                            );
                            return;
                          }
                          context.read<CallReportCubit>().submitReport(
                                callId: callId,
                                reason: reason,
                                description: description,
                              );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.favIcon,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Submit Report',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
