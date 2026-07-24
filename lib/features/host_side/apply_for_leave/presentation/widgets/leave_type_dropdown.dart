import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class LeaveTypeDropdown extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String> onChanged;

  const LeaveTypeDropdown({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  static const List<String> _leaveTypes = [
    'Sick Leave',
    'Casual Leave',
    'Annual Leave',
    'Maternity/Paternity Leave',
    'Other',
  ];

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Text(
                  'Select Leave Type',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              const Divider(height: 1),
              ..._leaveTypes.map((type) {
                final isSelected = type == selectedType;
                return ListTile(
                  title: Text(
                    type,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: isSelected ? AppColors.primaryColor : AppColors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryColor)
                      : null,
                  onTap: () {
                    onChanged(type);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leave Type',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () => _showBottomSheet(context),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: const Color(0xFFDCDDF7), width: 1.5),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF0FC),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.work_outline_rounded,
                    color: AppColors.primaryColor,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    selectedType ?? 'Select Leave Type',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: selectedType == null ? AppColors.subtitleText : AppColors.black,
                      fontWeight: selectedType == null ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.black,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
