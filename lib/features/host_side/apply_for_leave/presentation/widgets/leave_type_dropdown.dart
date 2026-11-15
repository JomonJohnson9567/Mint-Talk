import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_icon_square.dart';
import 'leave_form_field.dart';

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
      backgroundColor: AppColors.cardWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.cw),
                child: Text(
                  'Select Leave Type',
                  style: TextStyle(
                    fontSize: 18.csp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.plumDeep,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.profileDivider),
              ..._leaveTypes.map((type) {
                final isSelected = type == selectedType;
                return ListTile(
                  title: Text(
                    type,
                    style: TextStyle(
                      fontSize: 15.csp,
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.plumDeep,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryColor,
                        )
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
        const LeaveFieldLabel('Leave Type'),
        LeaveFieldBox(
          onTap: () => _showBottomSheet(context),
          child: Row(
            children: [
              const HostIconSquare(icon: Icons.work_outline_rounded),
              SizedBox(width: 14.cw),
              Expanded(
                child: Text(
                  selectedType ?? 'Select Leave Type',
                  style: TextStyle(
                    fontSize: 15.csp,
                    color: selectedType == null
                        ? AppColors.hostSubtitle
                        : AppColors.plumDeep,
                    fontWeight: selectedType == null
                        ? FontWeight.w400
                        : FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.plumDeep,
                size: 24.csp,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
