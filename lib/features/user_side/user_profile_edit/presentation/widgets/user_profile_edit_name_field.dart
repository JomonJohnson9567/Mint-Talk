import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Owns the name field's [TextEditingController] itself instead of relying
/// on a field's `initialValue`, which only ever seeds the field on its very
/// first build. `initialValue` alone can't reflect a name arriving later
/// from the cubit's async profile load, so this used to be keyed off
/// `state.fullName` to force a remount whenever it changed — which also
/// remounted (and stole focus from) the field on every single keystroke,
/// since `onChanged` emits a new `state.fullName` on every character.
/// Syncing the controller in [didUpdateWidget] instead picks up the
/// async-loaded name without ever touching focus while typing.
class UserProfileEditNameField extends StatefulWidget {
  const UserProfileEditNameField({
    super.key,
    required this.name,
    required this.errorText,
    required this.onChanged,
  });

  final String name;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  State<UserProfileEditNameField> createState() =>
      _UserProfileEditNameFieldState();
}

class _UserProfileEditNameFieldState extends State<UserProfileEditNameField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.name,
  );

  @override
  void didUpdateWidget(covariant UserProfileEditNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only external changes (the async profile load) land here — typing
    // routes through onChanged -> cubit -> this same widget.name, so it
    // already matches _controller.text by the time this runs and this is
    // a no-op, leaving focus/cursor untouched.
    if (widget.name != _controller.text) {
      _controller.text = widget.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.cw);
    OutlineInputBorder border(Color color, [double width = 1.5]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.cw),
          child: Text(
            AppTexts.fullNameLabel,
            style: TextStyle(
              fontSize: 13.csp,
              fontWeight: FontWeight.w700,
              color: AppColors.plumDeep,
            ),
          ),
        ),
        SizedBox(height: 8.cw),
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          cursorColor: AppColors.primaryColor,
          style: TextStyle(
            fontSize: 15.csp,
            fontWeight: FontWeight.w600,
            color: AppColors.plumDeep,
          ),
          decoration: InputDecoration(
            hintText: AppTexts.fullNameHint,
            hintStyle: TextStyle(
              fontSize: 15.csp,
              fontWeight: FontWeight.w400,
              color: AppColors.plumHint,
            ),
            errorText: widget.errorText,
            errorStyle: TextStyle(fontSize: 12.csp, color: Colors.red.shade700),
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              size: 20.csp,
              color: AppColors.primaryColor,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.cw,
              vertical: 15.cw,
            ),
            enabledBorder: border(AppColors.lavenderBorder),
            focusedBorder: border(AppColors.primaryColor),
            errorBorder: border(Colors.red.shade700),
            focusedErrorBorder: border(Colors.red.shade700),
          ),
        ),
      ],
    );
  }
}
