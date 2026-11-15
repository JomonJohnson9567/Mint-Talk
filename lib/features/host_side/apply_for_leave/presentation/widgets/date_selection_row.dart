import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_icon_square.dart';
import 'leave_form_field.dart';

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
    final DateTime resolvedFirstDate =
        firstDate ?? now.subtract(const Duration(days: 365));

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
              onSurface: AppColors.plumDeep,
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
        SizedBox(width: 14.cw),
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
        LeaveFieldLabel(label),
        LeaveFieldBox(
          onTap: onTap,
          padding: EdgeInsets.all(10.cw),
          child: Row(
            children: [
              const HostIconSquare(
                icon: Icons.calendar_today_outlined,
                size: 38,
              ),
              SizedBox(width: 10.cw),
              Expanded(
                child: Text(
                  dateText,
                  style: TextStyle(
                    fontSize: 14.csp,
                    color: isSelected
                        ? AppColors.plumDeep
                        : AppColors.hostSubtitle,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
