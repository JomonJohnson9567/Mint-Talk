import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/home/presentation/bloc/home_cubit.dart';

/// Time-of-day greeting with the MintTalk mascot, shown above the call cards.
class GreetingBanner extends StatelessWidget {
  const GreetingBanner({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppTexts.goodMorning;
    if (hour < 17) return AppTexts.goodAfternoon;
    return AppTexts.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final fullName = context.select<HomeCubit, String?>(
      (cubit) => cubit.state.userName,
    );
    final firstName = fullName?.trim().split(RegExp(r'\s+')).first ?? '';
    final title = firstName.isEmpty
        ? _greeting()
        : '${_greeting()}, $firstName';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 5.cw),
      child: Container(
        constraints: BoxConstraints(minHeight: 80.cw),
        decoration: BoxDecoration(
          color: AppColors.greetingBanner,
          borderRadius: BorderRadius.circular(20.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.cw, 10.cw, 4.cw, 10.cw),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17.csp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.plumDeep,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.cw),
                    Text(
                      AppTexts.greetingSubtitle,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12.csp,
                        color: AppColors.plumMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // The mascot image is opaque — its background matches
            // AppColors.greetingBanner, so it reads as part of the banner.
            Image.asset(
              AppAssets.homeMascot,
              height: 80.cw,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
