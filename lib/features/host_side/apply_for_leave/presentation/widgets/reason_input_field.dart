import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_icon_square.dart';
import 'leave_form_field.dart';

class ReasonInputField extends StatelessWidget {
  final String reason;
  final ValueChanged<String> onChanged;

  const ReasonInputField({
    super.key,
    required this.reason,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LeaveFieldLabel('Reason for leave'),
        LeaveFieldBox(
          padding: EdgeInsets.all(14.cw),
          child: SizedBox(
            height: 110.cw,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HostIconSquare(icon: Icons.edit_note_rounded),
                SizedBox(width: 14.cw),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.cw),
                    child: TextField(
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: AppTexts.leaveReasonHint,
                        hintStyle: TextStyle(
                          fontSize: 14.5.csp,
                          color: AppColors.hostSubtitle,
                          height: 1.4,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontSize: 14.5.csp,
                        color: AppColors.plumDeep,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
