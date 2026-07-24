import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class DateSelectionRow extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;

  const DateSelectionRow({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'dd/mm/yyyy';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    ValueChanged<DateTime> onSelected,
    DateTime? firstDate,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime resolvedFirstDate = firstDate ?? now.subtract(const Duration(days: 365));
    
    DateTime resolvedInitialDate = initialDate ?? now;
    if (resolvedInitialDate.isBefore(resolvedFirstDate)) {
      resolvedInitialDate = resolvedFirstDate;
    }
    
    final DateTime lastDate = now.add(const Duration(days: 365));
    if (resolvedInitialDate.isAfter(lastDate)) {
      resolvedInitialDate = lastDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: resolvedInitialDate,
      firstDate: resolvedFirstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DateSelector(
            label: 'Start Date',
            dateText: _formatDate(startDate),
            isSelected: startDate != null,
            onTap: () => _selectDate(
              context,
              startDate,
              onStartDateChanged,
              DateTime.now(),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _DateSelector(
            label: 'End Date',
            dateText: _formatDate(endDate),
            isSelected: endDate != null,
            onTap: () => _selectDate(
              context,
              endDate,
              onEndDateChanged,
              startDate ?? DateTime.now(),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final String dateText;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateSelector({
    required this.label,
    required this.dateText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: const Color(0xFFDCDDF7), width: 1.5),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF0FC),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primaryColor,
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isSelected ? AppColors.black : AppColors.subtitleText,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primaryColor,
                  size: 18.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
