import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_cubit.dart';

/// "Hello, {name}" banner with the headset mascot, above the call card.
class HostGreetingBanner extends StatelessWidget {
  const HostGreetingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final fullName = context.select<HostProfileCubit, String?>(
      (cubit) => cubit.state.fullName,
    );
    final firstName = fullName?.trim().split(RegExp(r'\s+')).first ?? '';
    final title = firstName.isEmpty
        ? AppTexts.hello
        : '${AppTexts.hello}, $firstName';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 5.cw),
      child: Container(
        constraints: BoxConstraints(minHeight: 120.cw),
        decoration: BoxDecoration(
          color: AppColors.hostGreetingBanner,
          borderRadius: BorderRadius.circular(22.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 11,
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.cw, 18.cw, 4.cw, 18.cw),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 23.csp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.plumDeep,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 6.cw),
                    Text(
                      AppTexts.hostGreetingSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5.csp,
                        color: AppColors.hostSubtitle,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // The mascot image is opaque — its background matches
            // AppColors.hostGreetingBanner, so it reads as part of the banner.
            // Takes ~45% of the card and pins the mascot to its bottom-right
            // corner, so the text keeps room on small phones.
            Expanded(
              flex: 9,
              child: Padding(
                padding: EdgeInsets.only(top: 6.cw),
                child: Image.asset(
                  AppAssets.hostGreetingMascot,
                  height: 112.cw,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
