import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_icons.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

/// A reusable iOS-style date picker bottom sheet with glass effect.
///
/// Shows a [CupertinoDatePicker] inside a modal bottom sheet.
/// [currentDob] is the currently selected date string in DD/MM/YYYY format (can be empty).
/// [onDateSelected] is called each time the user scrolls to a new date, with the formatted string.
class DobPickerBottomSheet {
  DobPickerBottomSheet._();

  static void show({
    required BuildContext context,
    required String currentDob,
    required ValueChanged<String> onDateSelected,
  }) {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(
      now.year - 18,
      now.month,
      now.day,
    );

    DateTime initialDate = eighteenYearsAgo;
    if (currentDob.isNotEmpty) {
      try {
        final parts = currentDob.split('/');
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext builder) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10.0,
              sigmaY: 10.0,
            ),
            child: Container(
              height: 350.h,
              decoration: const BoxDecoration(
                color: AppColors.white,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 24.w,
                      right: 16.w,
                      top: 16.h,
                      bottom: 8.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTexts.setYourBirthday,
                          style: TextStyle(
                            color: AppColors.actionBlue,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            AppIcons.close,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoTheme(
                      data: const CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: initialDate,
                        minimumDate: DateTime(1900),
                        maximumDate: now,
                        onDateTimeChanged: (DateTime newDate) {
                          final formatted =
                              "${newDate.day}/${newDate.month}/${newDate.year}";
                          onDateSelected(formatted);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
