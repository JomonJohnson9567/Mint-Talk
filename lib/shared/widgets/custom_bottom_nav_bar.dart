// ignore_for_file: deprecated_member_use

import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<IconData> icons;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        margin: EdgeInsets.only(left: 40.w, right: 40.w, bottom: 20.h),
        // Outer Container handles Shadow and Shape
        decoration: BoxDecoration(
          // No color here to allow transparency
          borderRadius: BorderRadius.circular(50.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(51),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        // ClipRRect to constrain the blur and background color
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              // Semi-transparent background
              decoration: BoxDecoration(
                color: AppColors.white.withAlpha(179),
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double totalWidth = constraints.maxWidth;
                    final double itemWidth = totalWidth / icons.length;
                    const double circleSize =
                        55; // Keep it fixed or use .w if needed

                    return Stack(
                      alignment: Alignment.centerLeft, // Helper alignment
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.fastOutSlowIn,
                          left:
                              itemWidth * currentIndex +
                              (itemWidth - circleSize.w) / 2,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: circleSize.w,
                            height: circleSize.w,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(icons.length, (index) {
                            final isSelected = index == currentIndex;
                            return SizedBox(
                              width: itemWidth,
                              child: GestureDetector(
                                onTap: () => onTap(index),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  height: 50.w,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    icons[index],
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.grey,
                                    size: 24.sp,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
