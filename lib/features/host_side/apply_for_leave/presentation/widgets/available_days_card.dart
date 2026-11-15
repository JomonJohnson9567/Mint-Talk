import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_icon_square.dart';

class AvailableDaysCard extends StatelessWidget {
  final int availableDays;

  const AvailableDaysCard({super.key, required this.availableDays});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.cw),
      decoration: BoxDecoration(
        color: AppColors.hostWaitingCard,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          const HostIconSquare(icon: Icons.calendar_today_outlined, size: 52),
          SizedBox(width: 16.cw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTexts.availableLeave,
                  style: TextStyle(
                    fontSize: 13.csp,
                    color: AppColors.hostSubtitle,
                  ),
                ),
                SizedBox(height: 2.cw),
                Text(
                  '$availableDays ${availableDays == 1 ? 'day' : 'days'}',
                  style: TextStyle(
                    fontSize: 26.csp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.plumDeep,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2.cw),
                Text(
                  AppTexts.remainingBalance,
                  style: TextStyle(
                    fontSize: 12.5.csp,
                    color: AppColors.hostSubtitle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
