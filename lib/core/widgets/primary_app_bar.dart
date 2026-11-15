import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_icons.dart';
import 'package:mint_talk/core/theme/color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;

  /// Colour of the title, back button and action icons.
  final Color foregroundColor;

  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.foregroundColor = AppColors.black,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      iconTheme: IconThemeData(color: foregroundColor),
      title: Text(
        title,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: actions,
      leading: automaticallyImplyLeading
          ? IconButton(
              tooltip: 'Back',
              icon: Icon(AppIcons.back, size: 24.sp),
              onPressed: () => Navigator.pop(context),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.h);
}
