// ignore_for_file: deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import '../cubit/country_search_cubit.dart';

class CountryPickerSheet extends StatelessWidget {
  const CountryPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Country',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                color: AppColors.black,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          TextField(
            onChanged: (value) =>
                context.read<CountrySearchCubit>().search(value),
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
              filled: true,
              fillColor: AppColors.grey.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: BlocBuilder<CountrySearchCubit, CountrySearchState>(
              builder: (context, state) {
                if (state.filteredCountries.isEmpty) {
                  return const Center(
                    child: Text(
                      'No countries found',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: state.filteredCountries.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: AppColors.grey.withOpacity(0.2)),
                  itemBuilder: (context, index) {
                    final country = state.filteredCountries[index];
                    return ListTile(
                      onTap: () => Navigator.pop(context, country),
                      leading: Text(
                        country.flagEmoji,
                        style: TextStyle(fontSize: 24.sp),
                      ),
                      title: Text(
                        country.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        '+${country.phoneCode}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
