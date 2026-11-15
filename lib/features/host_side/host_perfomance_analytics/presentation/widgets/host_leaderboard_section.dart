import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/features/host_side/host_perfomance_analytics/domain/entities/host_leaderboard_entry_entity.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_avatar.dart';

/// "Earning alongside you" — this week's minutes and earnings per host, with
/// the signed-in host's row highlighted.
class HostLeaderboardSection extends StatelessWidget {
  final List<HostLeaderboardEntryEntity> entries;

  const HostLeaderboardSection({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppTexts.earningAlongsideYou,
          style: TextStyle(
            fontSize: 19.csp,
            fontWeight: FontWeight.w800,
            color: AppColors.plumDeep,
          ),
        ),
        SizedBox(height: 2.cw),
        Text(
          AppTexts.thisWeeksHostActivity,
          style: TextStyle(fontSize: 13.csp, color: AppColors.hostSubtitle),
        ),
        SizedBox(height: 12.cw),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.profileDivider),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              const _HeaderRow(),
              for (var i = 0; i < entries.length; i++)
                _EntryRow(
                  entry: entries[i],
                  showDivider:
                      i != entries.length - 1 &&
                      !entries[i].isMe &&
                      !entries[i + 1].isMe,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

const _minutesFlex = 3;
const _earningsFlex = 3;
const _hostFlex = 4;

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 12.csp, color: AppColors.hostSubtitle);

    return Container(
      color: AppColors.hostVideoTileBg,
      padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 10.cw),
      child: Row(
        children: [
          Expanded(
            flex: _hostFlex,
            child: Text(AppTexts.leaderboardHost, style: style),
          ),
          Expanded(
            flex: _minutesFlex,
            child: Text(
              AppTexts.weeklyMinutes,
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          Expanded(
            flex: _earningsFlex,
            child: Text(
              AppTexts.weeklyEarnings,
              textAlign: TextAlign.end,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final HostLeaderboardEntryEntity entry;
  final bool showDivider;

  const _EntryRow({required this.entry, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 10.cw),
      child: Row(
        children: [
          Expanded(
            flex: _hostFlex,
            child: Row(
              children: [
                ClipOval(
                  child: HostProfileAvatar(
                    imagePath: entry.avatarUrl,
                    initials: entry.name.isEmpty ? '' : entry.name[0],
                    size: 44,
                  ),
                ),
                SizedBox(width: 10.cw),
                Flexible(child: _NameLabel(entry: entry)),
              ],
            ),
          ),
          Expanded(
            flex: _minutesFlex,
            child: Text(
              '${entry.minutes} min',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.csp, color: AppColors.plumDeep),
            ),
          ),
          Expanded(
            flex: _earningsFlex,
            child: Text(
              '₹${IndianNumberFormat.format(entry.earningsInr.round())}',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14.5.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
          ),
        ],
      ),
    );

    if (entry.isMe) {
      return Container(
        margin: EdgeInsets.all(4.cw),
        decoration: BoxDecoration(
          color: AppColors.hostVideoIconBg,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: row,
      );
    }

    return Column(
      children: [
        row,
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 14.cw,
            endIndent: 14.cw,
            color: AppColors.profileDivider,
          ),
      ],
    );
  }
}

class _NameLabel extends StatelessWidget {
  final HostLeaderboardEntryEntity entry;

  const _NameLabel({required this.entry});

  @override
  Widget build(BuildContext context) {
    final nameStyle = TextStyle(
      fontSize: 14.5.csp,
      fontWeight: entry.isMe ? FontWeight.w800 : FontWeight.w500,
      color: AppColors.plumDeep,
    );

    return Text.rich(
      TextSpan(
        text: entry.name,
        style: nameStyle,
        children: [
          if (entry.isMe)
            TextSpan(
              text: ' · ${AppTexts.youSuffix}',
              style: nameStyle.copyWith(color: AppColors.hostVideoAccent),
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
