import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';

/// Plum-styled birthday wheel for the user profile setup screen, with a live
/// preview of the picked date and age. Kept separate from the shared
/// `DobPickerBottomSheet`, which the host screens still use as-is.
///
/// Unlike that sheet, the date is only reported on Confirm. Under-18 dates
/// can be scrolled to, but they show an inline warning and disable Confirm.
class BirthdayPickerSheet extends StatefulWidget {
  const BirthdayPickerSheet._({required this.initialDate});

  final DateTime initialDate;

  /// [currentDob] is DD/MM/YYYY (may be empty). [onDateSelected] receives the
  /// confirmed date in the same `d/m/yyyy` form the DateOfBirth value object
  /// parses.
  static Future<void> show({
    required BuildContext context,
    required String currentDob,
    required ValueChanged<String> onDateSelected,
  }) async {
    final today = _today();
    var initial = _parse(currentDob) ?? _eighteenYearsAgo();
    if (initial.isAfter(today)) initial = today;

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: AppColors.cardWhite,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (_) => BirthdayPickerSheet._(initialDate: initial),
    );
    if (picked != null) {
      onDateSelected('${picked.day}/${picked.month}/${picked.year}');
    }
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime _eighteenYearsAgo() {
    final now = DateTime.now();
    return DateTime(now.year - _minAge, now.month, now.day);
  }

  // Mirrors the DateOfBirth value object's age check.
  static const int _minAge = 18;

  static DateTime? _parse(String dob) {
    final parts = dob.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  @override
  State<BirthdayPickerSheet> createState() => _BirthdayPickerSheetState();
}

class _BirthdayPickerSheetState extends State<BirthdayPickerSheet> {
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  late DateTime _selected = widget.initialDate;

  int get _age {
    final today = DateTime.now();
    var age = today.year - _selected.year;
    if (today.month < _selected.month ||
        (today.month == _selected.month && today.day < _selected.day)) {
      age--;
    }
    return age;
  }

  bool get _isUnderage => _age < BirthdayPickerSheet._minAge;

  void _onDateChanged(DateTime date) {
    final wasUnderage = _isUnderage;
    setState(() => _selected = date);
    // A firmer bump when crossing into under-age, a light tick otherwise.
    if (_isUnderage && !wasUnderage) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  String get _formatted =>
      '${_selected.day} ${_months[_selected.month - 1]} ${_selected.year}';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(),
            SizedBox(height: 16.h),
            _Preview(date: _formatted, age: _age, isUnderage: _isUnderage),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _isUnderage
                  ? const _UnderageWarning()
                  : const SizedBox(width: double.infinity),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 190.h,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: GoogleFonts.nunito(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.plumDeep,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  dateOrder: DatePickerDateOrder.dmy,
                  initialDateTime: widget.initialDate,
                  minimumDate: DateTime(1900),
                  maximumDate: BirthdayPickerSheet._today(),
                  itemExtent: 40.h,
                  selectionOverlayBuilder:
                      (
                        context, {
                        required selectedIndex,
                        required columnCount,
                      }) => _SelectionBand(
                        isFirst: selectedIndex == 0,
                        isLast: selectedIndex == columnCount - 1,
                      ),
                  onDateTimeChanged: _onDateChanged,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.plumMuted,
                      minimumSize: Size.fromHeight(48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      AppTexts.cancel,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    text: AppTexts.confirm,
                    height: 48.h,
                    textStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    disabledBackgroundColor: AppColors.primaryColor.withValues(
                      alpha: 0.22,
                    ),
                    disabledForegroundColor: AppColors.plumMuted,
                    onPressed: _isUnderage
                        ? null
                        : () => Navigator.pop(context, _selected),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: const BoxDecoration(
            color: AppColors.popularCardBg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cake_rounded,
            size: 22.sp,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTexts.whensYourBirthday,
                style: GoogleFonts.nunito(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.plumDeep,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                AppTexts.mustBe18,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.plumMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Picked date in words plus an age chip; both animate as the wheel turns,
/// and the card turns red while the date is under-age.
class _Preview extends StatelessWidget {
  const _Preview({
    required this.date,
    required this.age,
    required this.isUnderage,
  });

  final String date;
  final int age;
  final bool isUnderage;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isUnderage ? Colors.red.shade50 : AppColors.videoCardBg,
            AppColors.cardWhite,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isUnderage ? Colors.red.shade300 : AppColors.lavenderBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.centerLeft,
                children: [...previous, ?current],
              ),
              child: Text(
                date,
                key: ValueKey(date),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.plumDeep,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Container(
              key: ValueKey(age),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: isUnderage
                    ? Colors.red.shade700
                    : AppColors.primaryColor,
                borderRadius: BorderRadius.circular(99.r),
              ),
              child: Text(
                AppTexts.yearsOld(age),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnderageWarning extends StatelessWidget {
  const _UnderageWarning();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 18.sp,
              color: Colors.red.shade700,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                AppTexts.underageMessage,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft plum band on the selected row, rounded only at the outer ends so the
/// three columns read as one pill. The picker paints this overlay *above*
/// the wheel, so it must stay translucent or it hides the selected date.
class _SelectionBand extends StatelessWidget {
  const _SelectionBand({required this.isFirst, required this.isLast});

  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(14.r);

    return Container(
      margin: EdgeInsets.only(left: isFirst ? 4.w : 0, right: isLast ? 4.w : 0),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.horizontal(
          left: isFirst ? radius : Radius.zero,
          right: isLast ? radius : Radius.zero,
        ),
      ),
    );
  }
}
