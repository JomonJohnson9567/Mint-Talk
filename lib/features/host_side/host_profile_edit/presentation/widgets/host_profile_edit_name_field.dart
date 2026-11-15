import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Editable host name. Owns its [TextEditingController] so the name arriving
/// from the cubit's async profile load is reflected via [didUpdateWidget]
/// without remounting the field (which would steal focus on every keystroke).
class HostProfileEditNameField extends StatefulWidget {
  const HostProfileEditNameField({
    super.key,
    required this.name,
    required this.errorText,
    required this.onChanged,
  });

  final String name;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  State<HostProfileEditNameField> createState() =>
      _HostProfileEditNameFieldState();
}

class _HostProfileEditNameFieldState extends State<HostProfileEditNameField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.name,
  );

  @override
  void didUpdateWidget(covariant HostProfileEditNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Typing routes through onChanged -> cubit -> widget.name, so it already
    // matches here; only the async profile load actually updates the text.
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
