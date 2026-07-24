// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class _EarningBarData {
  final String date;
  final String month;
  final double amount;
  final String label;

  const _EarningBarData({
    required this.date,
    required this.month,
    required this.amount,
    required this.label,
  });
}

class EarningsBarChart extends StatelessWidget {
  const EarningsBarChart({super.key});

  static const List<_EarningBarData> _data = [
    _EarningBarData(date: '12', month: 'Jan', amount: 1100, label: '1.1k'),
    _EarningBarData(date: '13', month: 'Jan', amount: 989, label: '989'),
    _EarningBarData(date: '14', month: 'Jan', amount: 589, label: '589'),
    _EarningBarData(date: '15', month: 'Jan', amount: 992, label: '992'),
    _EarningBarData(date: '16', month: 'Jan', amount: 1020, label: '1.02k'),
    _EarningBarData(date: '17', month: 'Jan', amount: 1000, label: '1k'),
    _EarningBarData(date: 'Today', month: '', amount: 895, label: '895'),
  ];

  static const double _maxAmount = 1500;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChartHeader(),
          SizedBox(height: 16.h),
          _ChartBody(data: _data, maxAmount: _maxAmount),
        ],
      ),
    );
  }
}

class _ChartHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Last 7 Days Earnings',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
        const _PeriodDropdown(),
      ],
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderSoft),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Last 7 Days',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.subtitleText,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16.sp, color: AppColors.subtitleText),
        ],
      ),
    );
  }
}

class _ChartBody extends StatelessWidget {
  final List<_EarningBarData> data;
  final double maxAmount;

  const _ChartBody({required this.data, required this.maxAmount});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _YAxis(maxAmount: maxAmount),
          SizedBox(width: 8.w),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data
                  .map((d) => _BarColumn(data: d, maxAmount: maxAmount))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _YAxis extends StatelessWidget {
  final double maxAmount;

  const _YAxis({required this.maxAmount});

  @override
  Widget build(BuildContext context) {
    final labels = ['1.5k', '1k', '500', '0'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: labels
          .map(
            (l) => Text(
              l,
              style: TextStyle(
                fontSize: 9.sp,
                color: AppColors.subtitleText,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BarColumn extends StatelessWidget {
  final _EarningBarData data;
  final double maxAmount;

  const _BarColumn({required this.data, required this.maxAmount});

  @override
  Widget build(BuildContext context) {
    final chartHeight = 140.h;
    final barHeight = (data.amount / maxAmount) * chartHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          data.label,
          style: TextStyle(
            fontSize: 8.5.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          width: 28.w,
          height: barHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          data.date,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        if (data.month.isNotEmpty)
          Text(
            data.month,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.subtitleText,
            ),
          )
        else
          SizedBox(height: 12.h),
      ],
    );
  }
}
