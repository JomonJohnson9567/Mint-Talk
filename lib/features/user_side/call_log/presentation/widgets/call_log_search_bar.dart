import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/bloc/call_log_cubit.dart';

/// Pill search field; filters the loaded call logs by name as you type.
class CallLogSearchBar extends StatelessWidget {
  const CallLogSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(26.cw);
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide.none,
    );

    return TextField(
      onChanged: context.read<CallLogCubit>().search,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      textInputAction: TextInputAction.search,
      cursorColor: AppColors.primaryColor,
      style: TextStyle(
        fontSize: 14.5.csp,
        fontWeight: FontWeight.w500,
        color: AppColors.plumDeep,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.pillUnselected,
        hintText: AppTexts.searchCallHistory,
        hintStyle: TextStyle(
          fontSize: 14.5.csp,
          fontWeight: FontWeight.w500,
          color: AppColors.plumHint,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 14.cw, right: 8.cw),
          child: Icon(
            Icons.search_rounded,
            size: 24.csp,
            color: AppColors.plumMuted,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(),
        contentPadding: EdgeInsets.symmetric(vertical: 15.cw),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: AppColors.lavenderBorder,
            width: 1.2.cw,
          ),
        ),
      ),
    );
  }
}
