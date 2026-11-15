import 'package:flutter/material.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/home/presentation/bloc/home_state.dart';

/// Section title above the call-type hosts grid: a green dot with
/// "Available for video/audio" on the online tab, plain "All hosts"
/// otherwise. [trailing] sits at the right edge (e.g. a layout toggle).
class AvailableSectionTitle extends StatelessWidget {
  final HomeTab tab;
  final CallType callType;
  final Widget? trailing;

  const AvailableSectionTitle({
    super.key,
    required this.tab,
    required this.callType,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isOnlineTab = tab == HomeTab.active;
    final availableLabel = callType == CallType.video
        ? AppTexts.availableForVideo
        : AppTexts.availableForAudio;

    return Padding(
      padding: EdgeInsets.fromLTRB(14.cw, 8.cw, 14.cw, 6.cw),
      child: Row(
        children: [
          if (isOnlineTab) ...[
            Container(
              width: 10.cw,
              height: 10.cw,
              decoration: const BoxDecoration(
                color: AppColors.onlineIndicator,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.cw),
          ],
          Expanded(
            child: Text(
              isOnlineTab ? availableLabel : AppTexts.allHosts,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
