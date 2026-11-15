import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/home/presentation/bloc/home_cubit.dart';

/// Pill search box that filters the [HomeCubit] host list by name.
class HostSearchField extends StatefulWidget {
  const HostSearchField({super.key});

  @override
  State<HostSearchField> createState() => _HostSearchFieldState();
}

class _HostSearchFieldState extends State<HostSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    context.read<HomeCubit>().searchHosts('');
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(22.r),
      borderSide: BorderSide.none,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 5.cw),
      child: SizedBox(
        height: 40.cw,
        child: TextField(
          controller: _controller,
          onChanged: context.read<HomeCubit>().searchHosts,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: AppColors.primaryColor,
          style: TextStyle(fontSize: 14.csp, color: AppColors.plumDeep),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.videoCardBg,
            hintText: AppTexts.searchHosts,
            hintStyle: TextStyle(fontSize: 14.csp, color: AppColors.plumHint),
            contentPadding: EdgeInsets.zero,
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20.csp,
              color: AppColors.plumMuted,
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) => value.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      tooltip: 'Clear',
                      onPressed: _clear,
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18.csp,
                        color: AppColors.plumMuted,
                      ),
                    ),
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
        ),
      ),
    );
  }
}
