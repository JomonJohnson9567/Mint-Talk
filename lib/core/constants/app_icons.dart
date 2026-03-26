import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mint_talk/core/utils/platform_utils.dart';

class AppIcons {
  const AppIcons._();

  static IconData get back => PlatformUtils.select(
    android: Icons.arrow_back_ios,
    ios: CupertinoIcons.back,
  );

  static IconData get close =>
      PlatformUtils.select(android: Icons.close, ios: CupertinoIcons.xmark);

  static IconData get check => PlatformUtils.select(
    android: Icons.check,
    ios: CupertinoIcons.check_mark,
  );

  static IconData get settings => PlatformUtils.select(
    android: Icons.settings,
    ios: CupertinoIcons.settings,
  );

  static IconData get edit => PlatformUtils.select(
    android: Icons.edit,
    ios: CupertinoIcons.pencil_outline,
  );

  static IconData get delete =>
      PlatformUtils.select(android: Icons.delete, ios: CupertinoIcons.delete);

  static IconData get info => PlatformUtils.select(
    android: Icons.info_outline,
    ios: CupertinoIcons.info,
  );

  static IconData get search =>
      PlatformUtils.select(android: Icons.search, ios: CupertinoIcons.search);

  static IconData get person =>
      PlatformUtils.select(android: Icons.person, ios: CupertinoIcons.person);

  static IconData get camera => PlatformUtils.select(
    android: Icons.camera_alt_outlined,
    ios: CupertinoIcons.camera,
  );

  static IconData get arrowDown => PlatformUtils.select(
    android: Icons.keyboard_arrow_down,
    ios: CupertinoIcons.chevron_down,
  );

  static IconData get chevronRight => PlatformUtils.select(
    android: Icons.arrow_forward_ios_rounded,
    ios: CupertinoIcons.chevron_right,
  );

  static IconData get calendar => PlatformUtils.select(
    android: Icons.calendar_today_outlined,
    ios: CupertinoIcons.calendar,
  );

  static IconData get checkCircle => PlatformUtils.select(
    android: Icons.check_circle,
    ios: CupertinoIcons.check_mark_circled,
  );

  static IconData get home => PlatformUtils.select(
    android: Icons.home_rounded,
    ios: CupertinoIcons.house_fill,
  );

  static IconData get call =>
      PlatformUtils.select(android: Icons.call, ios: CupertinoIcons.phone_fill);

  static IconData get videoCall => PlatformUtils.select(
    android: Icons.videocam,
    ios: CupertinoIcons.videocam_fill,
  );

  static IconData get chat => PlatformUtils.select(
    android: Icons.message,
    ios: CupertinoIcons.chat_bubble_fill,
  );

  static IconData get heart => PlatformUtils.select(
    android: Icons.favorite,
    ios: CupertinoIcons.heart_fill,
  );

  static IconData get heartOutline => PlatformUtils.select(
    android: Icons.favorite_border,
    ios: CupertinoIcons.heart,
  );

  static IconData get block => PlatformUtils.select(
    android: Icons.block,
    ios: CupertinoIcons.slash_circle,
  );

  static IconData get logout => PlatformUtils.select(
    android: Icons.logout,
    ios: CupertinoIcons.square_arrow_right,
  );

  static IconData get document => PlatformUtils.select(
    android: Icons.description,
    ios: CupertinoIcons.doc_text,
  );

  static IconData get mail =>
      PlatformUtils.select(android: Icons.email, ios: CupertinoIcons.mail);

  static IconData get warning => PlatformUtils.select(
    android: Icons.warning_amber_rounded,
    ios: CupertinoIcons.exclamationmark_triangle,
  );

  static IconData get micOff => PlatformUtils.select(
    android: Icons.mic_off_outlined,
    ios: CupertinoIcons.mic_off,
  );

  static IconData get cameraSwitch => PlatformUtils.select(
    android: Icons.cameraswitch_outlined,
    ios: CupertinoIcons.camera_rotate,
  );

  static IconData get more => PlatformUtils.select(
    android: Icons.more_horiz,
    ios: CupertinoIcons.ellipsis,
  );

  static IconData get endCall => PlatformUtils.select(
    android: Icons.call_end,
    ios: CupertinoIcons.phone_down_fill,
  );

  static IconData get error => PlatformUtils.select(
    android: Icons.error_outline,
    ios: CupertinoIcons.exclamationmark_circle,
  );

  static IconData get filter => PlatformUtils.select(
    android: Icons.tune,
    ios: CupertinoIcons.slider_horizontal_3,
  );
}
