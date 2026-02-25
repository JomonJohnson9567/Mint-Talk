import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/top_snackbar.dart';
import '../cubit/snack_bar_cubit.dart';
import '../cubit/snack_bar_state.dart';

class SlidingSnackbarWrapper extends StatelessWidget {
  const SlidingSnackbarWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SnackBarCubit, SnackBarState>(
      builder: (context, state) {
        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              top: state.isVisible ? 0 : -150.h,
              left: 0,
              right: 0,
              child: SafeArea(
                child: TopSnackbar(
                  message: state.message,
                  backgroundColor: _getColor(state.type),
                  onDismiss: () {
                    context.read<SnackBarCubit>().hide();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color? _getColor(SnackBarType? type) {
    switch (type) {
      case SnackBarType.info:
        return Colors.blue;
      case SnackBarType.success:
        return Colors.green;
      case SnackBarType.error:
        return Colors.red;
      case SnackBarType.warning:
        return Colors.orange;
      default:
        return null;
    }
  }
}
